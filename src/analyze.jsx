// Analyze screens — entry, result, history
const AnalyzeEntry = ({ navigate, prefill }) => (
  <div className="scr">
    <StatusBar />
    <h1 className="title">Pose <span className="accent">Analysis</span></h1>
    <p className="subtitle">Upload or capture your pattern movement for instant feedback.</p>

    <div className="card stack-md" style={{marginBottom: 18}}>
      <div className="field">
        <label>Pattern</label>
        <select defaultValue={prefill ? "chon-ji" : "chon-ji"}>
          <option value="chon-ji">Chon-Ji (천지)</option>
          <option value="dan-gun">Dan-Gun (단군)</option>
          <option value="do-san">Do-San (도산)</option>
          <option value="won-hyo">Won-Hyo (원효)</option>
          <option value="yul-gok">Yul-Gok (율곡)</option>
        </select>
      </div>
      <div className="field">
        <label>Movement</label>
        <select defaultValue="m1">
          <option value="m1">Movement 1 — Walking stance low block</option>
          <option value="m2">Movement 2 — Walking stance middle punch</option>
          <option value="m3">Movement 3 — L-stance inner forearm block</option>
        </select>
      </div>
      {prefill && (
        <div style={{display: "flex", alignItems: "center", gap: 8, padding: "8px 12px", background: "rgba(59,130,246,0.08)", border: "1px solid rgba(59,130,246,0.2)", borderRadius: 10, fontSize: 11, color: "var(--secondary-2)"}}>
          <Icon name="zap" size={14}/> Pre-filled from Today's Focus
        </div>
      )}
    </div>

    <div style={{position: "relative", marginBottom: 18}}>
      <div className="ph" style={{height: 220, borderStyle: "dashed", borderWidth: 1.5, borderRadius: 22}}>
        <div style={{display: "flex", flexDirection: "column", alignItems: "center", gap: 10}}>
          <div style={{width: 56, height: 56, borderRadius: 16, background: "var(--grad-soft)", display: "grid", placeItems: "center"}}>
            <Icon name="scan" size={26} stroke="var(--primary)"/>
          </div>
          <div style={{fontSize: 14, fontWeight: 600, color: "var(--text)"}}>Upload your pose</div>
          <div style={{fontSize: 11, color: "var(--text-3)", textAlign: "center"}}>Take or upload a photo · auto-compared<br/>against the master reference</div>
        </div>
      </div>
    </div>

    <div style={{display: "grid", gridTemplateColumns: "1fr 1fr", gap: 12, marginBottom: 18}}>
      <button className="btn btn-secondary" style={{flexDirection: "column", padding: "20px 12px", height: "auto", gap: 10}}>
        <div style={{width: 44, height: 44, borderRadius: 12, background: "rgba(59,130,246,0.12)", display: "grid", placeItems: "center"}}>
          <Icon name="upload" size={20} stroke="var(--secondary)"/>
        </div>
        <span style={{fontSize: 13}}>Gallery</span>
      </button>
      <button className="btn btn-secondary" style={{flexDirection: "column", padding: "20px 12px", height: "auto", gap: 10}}>
        <div style={{width: 44, height: 44, borderRadius: 12, background: "rgba(239,68,68,0.12)", display: "grid", placeItems: "center"}}>
          <Icon name="camera" size={20} stroke="var(--primary)"/>
        </div>
        <span style={{fontSize: 13}}>Camera</span>
      </button>
    </div>

    <button className="btn btn-primary" onClick={() => navigate("analyzeResult")} style={{marginBottom: 16}}>Analyze Movement</button>

    <div className="card" style={{background: "var(--grad-soft)", borderColor: "rgba(239,68,68,0.18)"}}>
      <div style={{display: "flex", gap: 12}}>
        <div style={{width: 40, height: 40, borderRadius: 12, background: "rgba(239,68,68,0.2)", display: "grid", placeItems: "center", flexShrink: 0}}>
          <Icon name="activity" size={20} stroke="var(--primary)"/>
        </div>
        <div>
          <div style={{fontSize: 13, fontWeight: 600, marginBottom: 4}}>Compared to master reference</div>
          <div style={{fontSize: 11, color: "var(--text-2)", lineHeight: 1.5}}>Form, stance and technique are scored against the ITF reference for this exact movement.</div>
        </div>
      </div>
    </div>

    <div style={{marginTop: 18}}>
      <button className="btn-ghost" style={{background: "transparent", border: 0, color: "var(--primary)", fontSize: 13, cursor: "pointer", padding: 0}} onClick={() => navigate("analyzeHistory")}>View past analyses →</button>
    </div>
  </div>
);

const AnalyzeResult = ({ navigate, onBack }) => (
  <div className="scr">
    <StatusBar />
    <TopBar title="Analysis Result" onBack={onBack}/>

    <div style={{display: "grid", gridTemplateColumns: "1fr 1fr", gap: 10, marginBottom: 18}}>
      <div>
        <div className="tiny" style={{marginBottom: 6, color: "var(--primary)"}}>YOUR POSE</div>
        <Placeholder label={"your photo\nChon-Ji M1"} height={180} style={{borderRadius: 16}}/>
      </div>
      <div>
        <div className="tiny" style={{marginBottom: 6, color: "var(--secondary)"}}>MASTER REF</div>
        <Placeholder label={"reference\nwalking stance"} height={180} style={{borderRadius: 16}}/>
      </div>
    </div>

    <div className="card" style={{marginBottom: 18, textAlign: "center"}}>
      <div className="tiny" style={{textTransform: "uppercase", letterSpacing: "0.1em", marginBottom: 8}}>Overall score</div>
      <div className="gauge-num">68</div>
      <div className="micro" style={{marginTop: 8}}>Needs improvement · stance depth</div>
      <div className="progress-track" style={{marginTop: 14, background: "rgba(255,255,255,0.06)"}}>
        <div style={{height: "100%", width: "68%", background: "var(--grad)", borderRadius: 3}}/>
      </div>
      <div style={{display: "flex", justifyContent: "space-between", fontSize: 10, color: "var(--text-3)", marginTop: 6, fontFamily: "JetBrains Mono, monospace"}}>
        <span>0</span><span>50</span><span>100</span>
      </div>
    </div>

    <h3 className="card-h" style={{margin: "0 0 12px"}}>Detected issues</h3>
    <div className="stack-sm" style={{marginBottom: 20}}>
      {[
        {sev: "crit", tag: "Critical", title: "Front leg not bent enough", tip: "In walking stance the front knee should be over the toes — bend 15° more."},
        {sev: "impr", tag: "Improve", title: "Hip alignment slightly off", tip: "Rotate hips fully forward when blocking; engage your core."},
        {sev: "watch", tag: "Watch", title: "Blocking arm angle", tip: "Forearm should be at 45° from ground at end position."}
      ].map((iss, i) => (
        <div key={i} className="card compact" style={{padding: 16}}>
          <div style={{display: "flex", alignItems: "center", gap: 8, marginBottom: 8}}>
            <span className={`sev sev-${iss.sev}`}>{iss.tag}</span>
            <div style={{fontSize: 13, fontWeight: 600}}>{iss.title}</div>
          </div>
          <div style={{fontSize: 12, color: "var(--text-2)", lineHeight: 1.5, paddingLeft: 2}}>{iss.tip}</div>
        </div>
      ))}
    </div>

    <div className="stack-sm">
      <button className="btn btn-primary" onClick={onBack}><Icon name="check" size={16}/> Save to Journal</button>
      <div style={{display: "grid", gridTemplateColumns: "1fr 1fr", gap: 10}}>
        <button className="btn btn-secondary"><Icon name="refresh" size={16}/> Retry</button>
        <button className="btn btn-secondary" onClick={() => navigate("coach")}><Icon name="message" size={16}/> Ask Coach</button>
      </div>
    </div>
  </div>
);

const AnalyzeHistory = ({ onBack, navigate }) => (
  <div className="scr">
    <StatusBar />
    <TopBar title="Past Analyses" onBack={onBack}/>
    <div className="chips-row" style={{marginBottom: 16}}>
      <button className="chip on">All patterns</button>
      <button className="chip">Chon-Ji</button>
      <button className="chip">Dan-Gun</button>
      <button className="chip">Do-San</button>
    </div>
    <div className="stack-sm">
      {[
        {p: "Chon-Ji M1", d: "Today · 14:22", s: 68, c: "primary"},
        {p: "Chon-Ji M3", d: "Yesterday · 19:08", s: 74, c: "primary"},
        {p: "Dan-Gun M5", d: "May 8 · 21:00", s: 82, c: "secondary"},
        {p: "Chon-Ji M1", d: "May 7 · 18:30", s: 61, c: "primary"},
        {p: "Do-San M2", d: "May 5 · 20:15", s: 70, c: "accent"}
      ].map((r, i) => (
        <div key={i} className="card compact" style={{display: "flex", gap: 12, alignItems: "center", padding: 12, cursor: "pointer"}} onClick={() => navigate("analyzeResult")}>
          <Placeholder label="img" height={56} style={{width: 56, borderRadius: 12, flexShrink: 0}}/>
          <div style={{flex: 1}}>
            <div style={{fontSize: 13, fontWeight: 600}}>{r.p}</div>
            <div className="tiny">{r.d}</div>
          </div>
          <div style={{textAlign: "right"}}>
            <div style={{fontSize: 18, fontWeight: 700, background: "var(--grad)", WebkitBackgroundClip: "text", backgroundClip: "text", color: "transparent"}}>{r.s}</div>
            <div className="tiny">score</div>
          </div>
        </div>
      ))}
    </div>
  </div>
);

Object.assign(window, { AnalyzeEntry, AnalyzeResult, AnalyzeHistory });
