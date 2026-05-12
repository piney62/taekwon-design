"""
Pose analysis service.
- Extracts joints locally via MediaPipe Tasks API (original images never sent externally)
- Generates stick figures, then calls Groq Vision for AI feedback
"""

import base64
import os

import cv2
import httpx
import mediapipe as mp
import numpy as np

from ..core.config import settings
from .tul_db import TUL_DB, build_angle_text, build_prompt

# ─── Paths ────────────────────────────────────────────
_MODEL_PATH   = os.path.join(os.path.dirname(__file__), "pose_landmarker_full.task")
_MASTERS_DIR  = os.path.join(
    os.path.dirname(__file__), "..", "..", "static", "masters"
)

# ─── Stick figure config ──────────────────────────────
_CONNECTIONS = [
    (11, 12), (11, 13), (13, 15), (12, 14), (14, 16),
    (11, 23), (12, 24), (23, 24),
    (23, 25), (25, 27), (24, 26), (26, 28),
    (27, 31), (28, 32),
]
_COL_UPPER = (100, 200, 255)
_COL_BODY  = (200, 200, 200)
_COL_LOWER = (100, 255, 150)
_COL_HEAD  = (255, 220, 100)
_CONN_COLORS = {
    (11, 12): _COL_BODY,  (11, 23): _COL_BODY,
    (12, 24): _COL_BODY,  (23, 24): _COL_BODY,
    (11, 13): _COL_UPPER, (13, 15): _COL_UPPER,
    (12, 14): _COL_UPPER, (14, 16): _COL_UPPER,
    (23, 25): _COL_LOWER, (25, 27): _COL_LOWER,
    (24, 26): _COL_LOWER, (26, 28): _COL_LOWER,
    (27, 31): _COL_LOWER, (28, 32): _COL_LOWER,
}

GROQ_VISION_MODEL = "meta-llama/llama-4-scout-17b-16e-instruct"


# ─── MediaPipe Tasks API ──────────────────────────────

def _make_landmarker():
    base_options = mp.tasks.BaseOptions(model_asset_path=_MODEL_PATH)
    options = mp.tasks.vision.PoseLandmarkerOptions(
        base_options=base_options,
        num_poses=1,
        min_pose_detection_confidence=0.5,
        min_pose_presence_confidence=0.5,
        min_tracking_confidence=0.5,
    )
    return mp.tasks.vision.PoseLandmarker.create_from_options(options)


def extract_landmarks(image_bytes: bytes):
    """Extract MediaPipe landmarks from image bytes. Returns list[NormalizedLandmark]."""
    arr = np.frombuffer(image_bytes, np.uint8)
    img = cv2.imdecode(arr, cv2.IMREAD_COLOR)
    if img is None:
        return None
    rgb = cv2.cvtColor(img, cv2.COLOR_BGR2RGB)
    mp_image = mp.Image(image_format=mp.ImageFormat.SRGB, data=rgb)
    with _make_landmarker() as landmarker:
        result = landmarker.detect(mp_image)
    if not result.pose_landmarks:
        return None
    return result.pose_landmarks[0]   # list[NormalizedLandmark]


def draw_stick_figure(landmarks, size: int = 512) -> np.ndarray:
    """landmarks list → stick figure numpy array (BGR)."""
    canvas = np.zeros((size, size, 3), dtype=np.uint8)
    if not landmarks:
        return canvas

    def px(i):
        return (int(landmarks[i].x * size), int(landmarks[i].y * size))

    for (a, b), color in _CONN_COLORS.items():
        try:
            cv2.line(canvas, px(a), px(b), color, 4, cv2.LINE_AA)
        except Exception:
            pass

    for a, b in _CONNECTIONS:
        for i in [a, b]:
            try:
                c = (_COL_UPPER if i in range(11, 17)
                     else _COL_BODY if i in [23, 24]
                     else _COL_LOWER)
                cv2.circle(canvas, px(i), 8, c, -1, cv2.LINE_AA)
                cv2.circle(canvas, px(i), 8, (255, 255, 255), 2, cv2.LINE_AA)
            except Exception:
                pass

    try:
        nose = px(0)
        l_ear, r_ear = px(7), px(8)
        r = max(20, abs(l_ear[0] - r_ear[0]))
        cv2.circle(canvas, nose, r, _COL_HEAD, -1, cv2.LINE_AA)
        cv2.circle(canvas, nose, r, (255, 255, 255), 2, cv2.LINE_AA)
    except Exception:
        pass

    return canvas


# ─── Angle calculation ────────────────────────────────

def _calc_angle(a, b, c) -> float:
    a, b, c = np.array(a), np.array(b), np.array(c)
    ba, bc = a - b, c - b
    cos = np.dot(ba, bc) / (np.linalg.norm(ba) * np.linalg.norm(bc) + 1e-10)
    return round(float(np.degrees(np.arccos(np.clip(cos, -1, 1)))), 1)


def extract_angles(landmarks) -> dict:
    if not landmarks:
        return {}

    def pt(i):
        return [landmarks[i].x, landmarks[i].y]

    return {
        "left_elbow":    _calc_angle(pt(11), pt(13), pt(15)),
        "right_elbow":   _calc_angle(pt(12), pt(14), pt(16)),
        "left_shoulder": _calc_angle(pt(23), pt(11), pt(13)),
        "right_shoulder":_calc_angle(pt(24), pt(12), pt(14)),
        "left_knee":     _calc_angle(pt(23), pt(25), pt(27)),
        "right_knee":    _calc_angle(pt(24), pt(26), pt(28)),
        "left_hip":      _calc_angle(pt(11), pt(23), pt(25)),
        "right_hip":     _calc_angle(pt(12), pt(24), pt(26)),
    }


# ─── Stick figure → base64 ───────────────────────────

def _to_b64(arr: np.ndarray) -> str:
    _, buf = cv2.imencode(".png", arr)
    return base64.b64encode(buf).decode()


# ─── Groq Vision call ─────────────────────────────────

async def _call_groq_vision(
    master_b64: str,
    student_b64: str,
    prompt: str,
) -> str:
    api_key = settings.groq_api_key
    if not api_key:
        raise ValueError("Groq API key not configured")

    messages = [{
        "role": "user",
        "content": [
            {"type": "text", "text": "Master stick figure:"},
            {"type": "image_url", "image_url": {
                "url": f"data:image/png;base64,{master_b64}"}},
            {"type": "text", "text": "Student stick figure:"},
            {"type": "image_url", "image_url": {
                "url": f"data:image/png;base64,{student_b64}"}},
            {"type": "text", "text": prompt},
        ],
    }]

    payload = {
        "model": GROQ_VISION_MODEL,
        "messages": messages,
        "max_tokens": 1000,
    }

    async with httpx.AsyncClient(timeout=60, verify=False) as client:
        resp = await client.post(
            "https://api.groq.com/openai/v1/chat/completions",
            headers={
                "Authorization": f"Bearer {api_key}",
                "Content-Type": "application/json",
            },
            json=payload,
        )
        resp.raise_for_status()
        return resp.json()["choices"][0]["message"]["content"]


# ─── Master photo loading ─────────────────────────────

def _load_master_bytes(tul_id: str, movement_no: int) -> bytes:
    """Load bytes from static/masters/{tul_id}/{movement_no:02d}.jpg."""
    for ext in ("jpg", "jpeg", "png"):
        path = os.path.join(_MASTERS_DIR, tul_id, f"{movement_no:02d}.{ext}")
        if os.path.exists(path):
            with open(path, "rb") as f:
                return f.read()
    raise ValueError(
        f"Master photo not found: {tul_id}/{movement_no:02d}.jpg — "
        f"place it under static/masters/{tul_id}/"
    )


def master_image_exists(tul_id: str, movement_no: int) -> bool:
    for ext in ("jpg", "jpeg", "png"):
        path = os.path.join(_MASTERS_DIR, tul_id, f"{movement_no:02d}.{ext}")
        if os.path.exists(path):
            return True
    return False


# ─── Score calculation ────────────────────────────────

def compute_score(master_angles: dict, student_angles: dict) -> int:
    if not master_angles:
        return 0
    total_diff = 0.0
    for k, mv in master_angles.items():
        sv = float(student_angles.get(k, mv))
        total_diff += abs(sv - float(mv))
    avg = total_diff / len(master_angles)
    return int(max(0, min(100, round(100 - (avg / 30 * 100)))))


# ─── Public interface ─────────────────────────────────

async def analyze_pose(
    student_bytes: bytes,
    tul_name: str,
    movement_no: int,
    language: str = "ko",
) -> dict:
    """
    Master photo is loaded automatically from static/masters/.
    Returns:
        feedback: str       - AI coach feedback
        master_stick: str   - master stick figure base64
        student_stick: str  - student stick figure base64
        master_angles: dict - master joint angles
        student_angles: dict- student joint angles
    """
    master_bytes = _load_master_bytes(tul_name, movement_no)

    master_lm = extract_landmarks(master_bytes)
    student_lm = extract_landmarks(student_bytes)

    if not master_lm:
        raise ValueError("No person detected in master photo.")
    if not student_lm:
        raise ValueError("No person detected in student photo.")

    master_stick  = draw_stick_figure(master_lm)
    student_stick = draw_stick_figure(student_lm)
    master_angles = extract_angles(master_lm)
    student_angles = extract_angles(student_lm)

    master_b64  = _to_b64(master_stick)
    student_b64 = _to_b64(student_stick)

    angle_text = build_angle_text(master_angles, student_angles)
    prompt     = build_prompt(tul_name, movement_no, angle_text, language)

    feedback = await _call_groq_vision(master_b64, student_b64, prompt)
    score = compute_score(master_angles, student_angles)

    return {
        "feedback":       feedback,
        "master_stick":   master_b64,
        "student_stick":  student_b64,
        "master_angles":  master_angles,
        "student_angles": student_angles,
        "score":          score,
    }
