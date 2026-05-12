import httpx

from ..core.config import settings
from ..models.user import User
from ..schemas.coach import ChatMessage, ChatResponse


def _build_system_prompt(belt_level: str, language_code: str) -> str:
    return f"""You are an experienced ITF Taekwon-Do master coaching a student whose rank is "{belt_level} belt".

Guidelines:
- Detect the language the student writes in and always respond in that exact same language.
  - Korean input → respond in Korean using proper 한글 script (NOT romanization).
  - English input → respond in English.
  - Spanish input → respond in Spanish.
- Reference the official ITF Taekwon-Do Encyclopedia (Gen. Choi Hong-Hi) for technical accuracy.
- For beginners (white/yellow belts), use simple language without heavy terminology.
- For intermediate (green/blue/red), use Korean technical terms with brief explanations.
- Be encouraging, concise (3-6 sentences), and actionable.
- If asked about something outside Taekwon-Do, politely redirect.
"""


async def chat(user: User, messages: list[ChatMessage]) -> ChatResponse:
    provider = user.ai_provider
    system_prompt = _build_system_prompt(user.belt_level, user.language_code)

    if provider == "groq":
        return await _call_groq(system_prompt, messages)
    elif provider == "grok":
        return await _call_grok(system_prompt, messages)
    elif provider == "claude":
        return await _call_claude(system_prompt, messages)
    else:
        return await _call_groq(system_prompt, messages)


async def _call_groq(
    system_prompt: str, messages: list[ChatMessage]
) -> ChatResponse:
    api_key = settings.groq_api_key
    if not api_key:
        raise ValueError("Groq API key not configured on server")

    payload = {
        "model": "llama-3.3-70b-versatile",
        "max_tokens": 1024,
        "messages": [{"role": "system", "content": system_prompt}]
        + [{"role": m.role, "content": m.content} for m in messages],
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
        data = resp.json()
        return ChatResponse(reply=data["choices"][0]["message"]["content"])


async def _call_grok(
    system_prompt: str, messages: list[ChatMessage]
) -> ChatResponse:
    api_key = settings.grok_api_key
    if not api_key:
        raise ValueError("Grok API key not configured on server")

    payload = {
        "model": "grok-3-mini",
        "max_tokens": 1024,
        "messages": [{"role": "system", "content": system_prompt}]
        + [{"role": m.role, "content": m.content} for m in messages],
    }

    async with httpx.AsyncClient(timeout=60, verify=False) as client:
        resp = await client.post(
            "https://api.x.ai/v1/chat/completions",
            headers={
                "Authorization": f"Bearer {api_key}",
                "Content-Type": "application/json",
            },
            json=payload,
        )
        resp.raise_for_status()
        data = resp.json()
        return ChatResponse(reply=data["choices"][0]["message"]["content"])


async def _call_claude(
    system_prompt: str, messages: list[ChatMessage]
) -> ChatResponse:
    api_key = settings.anthropic_api_key
    if not api_key:
        raise ValueError("Anthropic API key not configured on server")

    payload = {
        "model": "claude-haiku-4-5-20251001",
        "max_tokens": 1024,
        "system": system_prompt,
        "messages": [{"role": m.role, "content": m.content} for m in messages],
    }

    async with httpx.AsyncClient(timeout=60, verify=False) as client:
        resp = await client.post(
            "https://api.anthropic.com/v1/messages",
            headers={
                "x-api-key": api_key,
                "anthropic-version": "2023-06-01",
                "Content-Type": "application/json",
            },
            json=payload,
        )
        resp.raise_for_status()
        data = resp.json()
        return ChatResponse(reply=data["content"][0]["text"])
