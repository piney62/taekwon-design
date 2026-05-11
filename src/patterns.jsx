// Patterns + reference materials
const patternsList = [
  {n: 1, name: "Chon-Ji", kor: "천지", moves: 19, belt: "White-Yellow", locked: false, cur: true},
  {n: 2, name: "Dan-Gun", kor: "단군", moves: 21, belt: "Yellow", locked: false},
  {n: 3, name: "Do-San", kor: "도산", moves: 24, belt: "Yellow-Green", locked: false},
  {n: 4, name: "Won-Hyo", kor: "원효", moves: 28, belt: "Green", locked: false},
  {n: 5, name: "Yul-Gok", kor: "율곡", moves: 38, belt: "Green-Blue", locked: false},
  {n: 6, name: "Joong-Gun", kor: "중근", moves: 32, belt: "Blue", locked: true},
  {n: 7, name: "Toi-Gye", kor: "퇴계", moves: 37, belt: "Blue-Red", locked: true},
  {n: 8, name: "Hwa-Rang", kor: "화랑", moves: 29, belt: "Red", locked: true},
  {n: 9, name: "Choong-Moo", kor: "충무", moves: 30, belt: "Red-Black", locked: true},
];

const PatternsMain = ({ navigate }) => (
  <div className="scr">
    <StatusBar />
    <h1 className="title">ITF Patterns <span style={{fontSize: 18, color: "var(--text-3)", fontWeight: 400}}>(틀)</span></h1>
    <p className="subtitle">Master all 24 ITF Taekwon-Do patterns.</p>

    <div style={{position: "relative", marginBottom: 18}}>
      <Icon name="search" size={18} stroke="var(--text-3)" style={{position: "absolute", left: 14, top: "50%", transform: "translateY(-50%)"}}/>
      <input placeholder="Search patterns..." style={{width: "100%", background: "var(--card)", border: "1px solid var(--border)", color: "var(--text)", padding: "14px 14px 14px 44px", borderRadius: 14, fontSize: 14, fontFamily: "inherit"}}/>
    </div>

    <div style={{marginBottom: 20}}>
      <FeatureCard
        label="Current Pattern"
        title="Chon-Ji (천지)"
        body="19 movements · White-Yellow Belt"
        progress={65}
        primaryLabel="Study Now"
        secondaryLabel="Details"
        onPrimary={() => navigate("patternDetail")}
        onSecondary={() => navigate("patternDetail")}
        icon="book"
      />
    </div>

    <h3 className="card-h" style={{marginBottom: 12}}>All Patterns (24)</h3>
    <div className="stack-sm" style={{marginBottom: 22}}>
      {patternsList.map(p => (
        <div key={p.n} className="card compact" style={{padding: 12, display: "flex", alignItems: "center", gap: 12, cursor: "pointer", opacity: p.locked ? 0.55 : 1}} onClick={() => !p.locked && navigate("patternDetail")}>
          <div style={{width: 40, height: 40, borderRadius: 11, background: p.cur ? "var(--grad)" : p.locked ? "var(--muted)" : "var(--grad-soft)", display: "grid", placeItems: "center", flexShrink: 0}}>
            {p.locked ? <Icon name="lock" size={16} stroke="var(--text-3)"/> : <span style={{fontSize: 13, fontWeight: 700, color: p.cur ? "white" : "var(--text)"}}>{p.n}</span>}
          </div>
          <div style={{flex: 1}}>
            <div style={{fontSize: 14, fontWeight: 600}}>{p.name} <span style={{color: "var(--text-3)", fontWeight: 400}}>({p.kor})</span></div>
            <div className="tiny">{p.moves} movements · {p.belt}</div>
          </div>
          <Icon name="chevron" size={16} stroke="var(--text-3)"/>
        </div>
      ))}
    </div>

    <div className="card">
      <h3 className="card-h" style={{marginBottom: 14}}>ITF Reference</h3>
      <div className="stack-sm">
        <ListRow icon="library" iconColor="primary" title="Terminology Dictionary" sub="Korean terms · stances, blocks, kicks" onClick={() => navigate("terminology")}/>
        <ListRow icon="award" iconColor="secondary" title="5 Tenets (오대정신)" sub="Courtesy, Integrity, Perseverance..." onClick={() => navigate("tenets")}/>
        <ListRow icon="book" iconColor="accent" title="ITF History" sub="Timeline from founding to today" onClick={() => navigate("history")}/>
        <ListRow icon="message" iconColor="primary" title="Coach (chat)" sub="Ask anything about technique" onClick={() => navigate("coach")}/>
      </div>
    </div>
  </div>
);

const PatternDetail = ({ onBack }) => {
  const [tab, setTab] = React.useState("image");
  const [dir, setDir] = React.useState("front");
  const [m, setM] = React.useState(1);
  return (
    <div className="scr">
      <StatusBar />
      <TopBar title={<span>1 · Chon-Ji <span style={{color: "var(--text-3)", fontWeight: 500}}>(천지)</span></span>} onBack={onBack}/>

      <div className="seg" style={{marginBottom: 16}}>
        <button className={tab === "image" ? "on" : ""} onClick={() => setTab("image")}>Image Study</button>
        <button className={tab === "video" ? "on" : ""} onClick={() => setTab("video")}>Video Study</button>
      </div>

      {tab === "image" ? (
        <>
          <Placeholder label={`reference photo\nM${m} · ${dir} view`} height={280} style={{marginBottom: 14}}/>
          <div className="seg" style={{marginBottom: 18}}>
            {["front","back","left","right"].map(d => (
              <button key={d} className={dir === d ? "on" : ""} onClick={() => setDir(d)}>{d[0].toUpperCase() + d.slice(1)}</button>
            ))}
          </div>
          <div className="card compact" style={{display: "flex", alignItems: "center", justifyContent: "space-between", padding: 14, marginBottom: 18}}>
            <button onClick={() => setM(Math.max(1, m-1))} style={{background: "transparent", border: 0, color: "var(--text)", cursor: "pointer", display: "flex", alignItems: "center", gap: 6, fontSize: 13, fontFamily: "inherit"}}><Icon name="chevronLeft" size={16}/> Prev</button>
            <div style={{textAlign: "center"}}>
              <div style={{fontSize: 11, color: "var(--text-3)", fontFamily: "JetBrains Mono, monospace"}}>MOVEMENT</div>
              <div style={{fontSize: 14, fontWeight: 600}}>{m} of 19</div>
            </div>
            <button onClick={() => setM(Math.min(19, m+1))} style={{background: "transparent", border: 0, color: "var(--text)", cursor: "pointer", display: "flex", alignItems: "center", gap: 6, fontSize: 13, fontFamily: "inherit"}}>Next <Icon name="chevron" size={16}/></button>
          </div>
        </>
      ) : (
        <div style={{position: "relative", marginBottom: 18}}>
          <Placeholder label="video player" height={220}/>
          <div style={{position: "absolute", inset: 0, display: "grid", placeItems: "center", pointerEvents: "none"}}>
            <div style={{width: 64, height: 64, borderRadius: "50%", background: "rgba(0,0,0,0.6)", backdropFilter: "blur(8px)", display: "grid", placeItems: "center"}}>
              <Icon name="play" size={28} stroke="white"/>
            </div>
          </div>
          <div style={{position: "absolute", bottom: 14, left: 14, right: 14, display: "flex", alignItems: "center", gap: 10, color: "white"}}>
            <span style={{fontSize: 11, fontFamily: "JetBrains Mono, monospace"}}>0:24</span>
            <div className="progress-track" style={{flex: 1, background: "rgba(255,255,255,0.2)"}}><div className="progress-fill" style={{width: "32%"}}/></div>
            <span style={{fontSize: 11, fontFamily: "JetBrains Mono, monospace"}}>1:14</span>
          </div>
        </div>
      )}

      <h3 className="card-h" style={{marginBottom: 10}}>About Chon-Ji</h3>
      <p style={{fontSize: 13, color: "var(--text-2)", lineHeight: 1.6, margin: 0}}>
        Chon-Ji means literally "the Heaven the Earth." It is, in the Orient, interpreted as the creation of the world or the beginning of human history. The pattern consists of two similar parts; one representing the Heaven and the other the Earth.
      </p>
    </div>
  );
};

const TerminologyScreen = ({ onBack }) => {
  const [cat, setCat] = React.useState("stance");
  const data = {
    stance: [
      {ko: "앞굽이", ro: "Ap kubi", en: "Walking stance", d: "Front leg bent, back leg straight."},
      {ko: "뒷굽이", ro: "Dwit kubi", en: "L-stance", d: "70% weight on back leg, foot at 90°."},
      {ko: "주춤서기", ro: "Joochum sogi", en: "Sitting stance", d: "Equal weight, knees bent outward."},
    ],
    block: [
      {ko: "내려막기", ro: "Naeryeo makgi", en: "Low block", d: "Forearm sweeps downward across body."},
      {ko: "안팔목막기", ro: "An palmok makgi", en: "Inner forearm block", d: "Inside edge blocks toward center."},
      {ko: "올려막기", ro: "Olryeo makgi", en: "High block", d: "Forearm rises above forehead."},
    ],
    kick: [
      {ko: "앞차기", ro: "Ap chagi", en: "Front kick", d: "Knee chambers, foot snaps forward."},
      {ko: "돌려차기", ro: "Dollyo chagi", en: "Turning (roundhouse) kick", d: "Hip rotates, instep strikes target."},
    ],
    strike: [
      {ko: "주먹지르기", ro: "Jumeok jireugi", en: "Punch", d: "Fist drives in straight line to target."},
      {ko: "손칼치기", ro: "Sonkal chigi", en: "Knife-hand strike", d: "Edge of open hand strikes outward."},
    ]
  };
  return (
    <div className="scr">
      <StatusBar />
      <TopBar title="Terminology" onBack={onBack}/>
      <div className="chips-row" style={{marginBottom: 14}}>
        {[["stance","Stances"],["block","Blocks"],["kick","Kicks"],["strike","Strikes"]].map(([k,l]) => (
          <button key={k} className={`chip ${cat === k ? "on" : ""}`} onClick={() => setCat(k)}>{l}</button>
        ))}
      </div>
      <div style={{position: "relative", marginBottom: 14}}>
        <Icon name="search" size={16} stroke="var(--text-3)" style={{position: "absolute", left: 14, top: "50%", transform: "translateY(-50%)"}}/>
        <input placeholder="Search Korean or English..." style={{width: "100%", background: "var(--card)", border: "1px solid var(--border)", color: "var(--text)", padding: "12px 14px 12px 42px", borderRadius: 12, fontSize: 13, fontFamily: "inherit"}}/>
      </div>
      <div className="stack-sm">
        {data[cat].map((t, i) => (
          <div key={i} className="card compact" style={{padding: 14}}>
            <div className="card-row" style={{marginBottom: 4}}>
              <div style={{fontSize: 17, fontWeight: 700, fontFamily: "'Noto Sans KR', sans-serif"}}>{t.ko}</div>
              <div style={{fontSize: 11, color: "var(--text-3)", fontFamily: "JetBrains Mono, monospace"}}>{t.ro}</div>
            </div>
            <div style={{fontSize: 13, fontWeight: 500, marginBottom: 4, color: "var(--primary-2)"}}>{t.en}</div>
            <div style={{fontSize: 12, color: "var(--text-2)", lineHeight: 1.5}}>{t.d}</div>
          </div>
        ))}
      </div>
    </div>
  );
};

const TenetsScreen = ({ onBack }) => {
  const tenets = [
    {en: "Courtesy", ko: "예의", han: "禮儀", c: "primary", d: "Respect senior and junior students; bow on entering the dojang."},
    {en: "Integrity", ko: "염치", han: "廉恥", c: "secondary", d: "Know what is right; have the will to live by it."},
    {en: "Perseverance", ko: "인내", han: "忍耐", c: "accent", d: "Patience and persistence overcome every obstacle."},
    {en: "Self-Control", ko: "극기", han: "克己", c: "primary", d: "Master your impulses, both in training and outside."},
    {en: "Indomitable Spirit", ko: "백절불굴", han: "百折不屈", c: "secondary", d: "Stand firm in the face of any adversity."},
  ];
  return (
    <div className="scr">
      <StatusBar />
      <TopBar title="5 Tenets (오대정신)" onBack={onBack}/>
      <div className="stack-sm">
        {tenets.map((t, i) => (
          <div key={i} className="card" style={{padding: 18}}>
            <div style={{display: "flex", alignItems: "center", gap: 14, marginBottom: 10}}>
              <div className={`icon-chip chip-${t.c}`} style={{width: 44, height: 44, borderRadius: 13, display: "grid", placeItems: "center"}}>
                <span style={{fontSize: 18, fontFamily: "'Noto Sans KR', serif", fontWeight: 700, color: t.c === "primary" ? "var(--primary)" : t.c === "secondary" ? "var(--secondary)" : "var(--accent)"}}>{t.han[0]}</span>
              </div>
              <div>
                <div style={{fontSize: 16, fontWeight: 700}}>{t.en}</div>
                <div style={{fontSize: 12, color: "var(--text-3)"}}>{t.ko} · {t.han}</div>
              </div>
            </div>
            <div style={{fontSize: 13, color: "var(--text-2)", lineHeight: 1.6}}>{t.d}</div>
          </div>
        ))}
      </div>
    </div>
  );
};

const HistoryScreen = ({ onBack }) => (
  <div className="scr">
    <StatusBar />
    <TopBar title="ITF History" onBack={onBack}/>
    <div className="timeline">
      {[
        {y: "1955", t: "Name 'Taekwon-Do' adopted", d: "On 11 April 1955 the name was officially decided by a special board."},
        {y: "1966", t: "ITF founded", d: "International Taekwon-Do Federation established by General Choi Hong Hi."},
        {y: "1972", t: "ITF HQ moves to Toronto", d: "International base relocated; first World Championship follows shortly after."},
        {y: "1983", t: "Encyclopedia published", d: "15-volume Taekwon-Do Encyclopedia codifies the art's full curriculum."},
        {y: "2002", t: "Passing of the founder", d: "General Choi Hong Hi passes; ITF continues under his lineage.", future: false},
        {y: "Today", t: "Global practice", d: "Over 90 countries practice ITF Taekwon-Do.", future: true},
      ].map((m, i) => (
        <div key={i} className={`tl-item ${m.future ? "future" : ""}`}>
          <div className="yr">{m.y}</div>
          <h4 className="ttl">{m.t}</h4>
          <p className="desc">{m.d}</p>
        </div>
      ))}
    </div>
  </div>
);

const CoachScreen = ({ onBack }) => {
  const [msgs, setMsgs] = React.useState([
    {by: "ai", t: "Annyeong! I'm your training companion. Ask me anything about ITF Taekwon-Do — patterns, terminology, technique, or what to practice next."},
  ]);
  const [draft, setDraft] = React.useState("");
  const send = (text) => {
    const t = (text || draft).trim();
    if (!t) return;
    setMsgs(m => [...m, {by: "user", t}, {by: "ai", t: "Great question — let's break it down. The walking stance (앞굽이) puts 70% of your weight on the front leg, which should be bent so the knee aligns over the toes. Try this drill: hold the stance for 30s on each side, twice."}]);
    setDraft("");
  };
  return (
    <div className="scr" style={{display: "flex", flexDirection: "column", minHeight: "100%", paddingBottom: 20}}>
      <StatusBar />
      <TopBar title="Coach" onBack={onBack} action={<button style={{background: "var(--card)", border: "1px solid var(--border)", width: 40, height: 40, borderRadius: 12, color: "var(--text-2)", display: "grid", placeItems: "center", cursor: "pointer"}}><Icon name="refresh" size={16}/></button>}/>

      <div style={{flex: 1}}>
        <div className="chat-stream">
          {msgs.map((m, i) => <div key={i} className={`bubble ${m.by}`}>{m.t}</div>)}
        </div>
      </div>

      <div style={{marginTop: 18}}>
        <div className="suggest-row">
          {["What should I practice today?", "Explain the 5 tenets", "What is ap kubi stance?", "Improve my Chon-Ji"].map((s, i) => (
            <button key={i} className="suggest" onClick={() => send(s)}>{s}</button>
          ))}
        </div>
        <div style={{display: "flex", gap: 10, alignItems: "center"}}>
          <input value={draft} onChange={e => setDraft(e.target.value)} onKeyDown={e => e.key === "Enter" && send()} placeholder="Ask anything..." style={{flex: 1, background: "var(--card)", border: "1px solid var(--border)", color: "var(--text)", padding: "14px 16px", borderRadius: 14, fontSize: 14, fontFamily: "inherit"}}/>
          <button onClick={() => send()} style={{width: 48, height: 48, borderRadius: 14, background: "var(--grad)", border: 0, color: "white", display: "grid", placeItems: "center", cursor: "pointer", flexShrink: 0}}><Icon name="send" size={18}/></button>
        </div>
      </div>
    </div>
  );
};

Object.assign(window, { PatternsMain, PatternDetail, TerminologyScreen, TenetsScreen, HistoryScreen, CoachScreen });
