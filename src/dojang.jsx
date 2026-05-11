// Dojang screens — instructor only
const DojangMain = ({ navigate, openModal }) => (
  <div className="scr">
    <StatusBar />
    <div style={{display: "flex", justifyContent: "space-between", alignItems: "flex-start"}}>
      <div>
        <h1 className="title"><span className="accent">Dojang</span></h1>
        <p className="subtitle">Manage students and homework.</p>
      </div>
      <button style={{width: 40, height: 40, borderRadius: 12, background: "var(--card)", border: "1px solid var(--border)", color: "var(--text)", display: "grid", placeItems: "center", cursor: "pointer", marginTop: 12}}><Icon name="refresh" size={16}/></button>
    </div>

    <div className="card" style={{marginBottom: 18, background: "linear-gradient(135deg, rgba(139,92,246,0.12), rgba(59,130,246,0.08))", borderColor: "rgba(139,92,246,0.2)"}}>
      <div className="card-row" style={{marginBottom: 14}}>
        <h3 className="card-h">Invite Code</h3>
        <span className="badge badge-green">Active</span>
      </div>
      <div style={{display: "flex", alignItems: "center", gap: 14}}>
        <div style={{width: 64, height: 64, background: "white", borderRadius: 12, display: "grid", placeItems: "center", flexShrink: 0}}>
          <Icon name="qr" size={36} stroke="#000"/>
        </div>
        <div style={{flex: 1}}>
          <div style={{fontSize: 18, fontWeight: 700, fontFamily: "JetBrains Mono, monospace", letterSpacing: "0.06em"}}>KIMSOUL2026</div>
          <div className="tiny" style={{marginTop: 4}}>Expires May 18 · 12 used</div>
        </div>
      </div>
      <div style={{display: "flex", gap: 8, marginTop: 14}}>
        <button className="btn btn-secondary" style={{padding: "10px 12px", fontSize: 12}} onClick={() => navigate("inviteModal")}><Icon name="qr" size={14}/> Open QR</button>
        <button className="btn btn-secondary" style={{padding: "10px 12px", fontSize: 12}}><Icon name="share" size={14}/> Share</button>
        <button className="btn btn-secondary" style={{padding: "10px 12px", fontSize: 12}}><Icon name="copy" size={14}/></button>
      </div>
    </div>

    <div className="card" style={{marginBottom: 18}}>
      <h3 className="card-h" style={{marginBottom: 12}}>Assign Homework</h3>
      <div className="field" style={{marginBottom: 12}}>
        <textarea rows="3" placeholder="e.g. Practice low block 100x. Submit a Chon-Ji M1 analysis." defaultValue="Practice low block 100x. Submit a Chon-Ji M1 analysis." style={{width: "100%", background: "var(--muted)", border: "1px solid var(--border)", color: "var(--text)", padding: "12px 14px", borderRadius: 12, fontSize: 13, fontFamily: "inherit", resize: "none"}}/>
        <div className="helper" style={{marginTop: 4, textAlign: "right"}}>52 / 200</div>
      </div>
      <div className="field" style={{marginBottom: 14}}>
        <label>Due date</label>
        <input type="date" defaultValue="2026-05-18"/>
      </div>
      <button className="btn btn-primary"><Icon name="plus" size={16}/> Assign to all students</button>
    </div>

    <div className="card-row" style={{marginBottom: 12, padding: "0 4px"}}>
      <h3 className="card-h">Students (28)</h3>
      <div className="chips-row" style={{gap: 6}}>
        <button className="chip on" style={{padding: "6px 10px", fontSize: 11}}>All</button>
        <button className="chip" style={{padding: "6px 10px", fontSize: 11}}>Idle</button>
      </div>
    </div>
    <div className="stack-sm">
      {[
        {n: "Jiwon Park", b: "Yellow Belt", l: "Active 8d ago", c: "yellow", alert: true},
        {n: "Alex Chen", b: "Green Belt", l: "Active today", c: "green"},
        {n: "Sara Lee", b: "Yellow Belt", l: "Active 2d ago", c: "yellow"},
        {n: "Marco Rossi", b: "Blue Belt", l: "Active today", c: "blue"},
        {n: "Nina Yamada", b: "Yellow-Green", l: "Active 4h ago", c: "yellow"},
        {n: "David Kim", b: "Green Belt", l: "Active yesterday", c: "green"},
      ].map((s, i) => (
        <div key={i} className="card compact" style={{padding: 12, display: "flex", alignItems: "center", gap: 12, cursor: "pointer"}} onClick={() => navigate("studentDetail")}>
          <div style={{width: 44, height: 44, borderRadius: 13, background: "var(--grad-soft)", display: "grid", placeItems: "center", color: "var(--text)", fontWeight: 700, fontSize: 14, position: "relative", flexShrink: 0}}>
            {s.n.split(" ").map(x => x[0]).join("")}
            {s.alert && <div style={{position: "absolute", top: -2, right: -2, width: 12, height: 12, borderRadius: "50%", background: "var(--primary)", border: "2px solid var(--stage)"}}/>}
          </div>
          <div style={{flex: 1}}>
            <div style={{fontSize: 14, fontWeight: 600}}>{s.n}</div>
            <div className="tiny">{s.l}</div>
          </div>
          <span className={`badge badge-${s.c}`}>{s.b}</span>
        </div>
      ))}
    </div>
  </div>
);

const InviteModal = ({ onClose }) => (
  <Modal onClose={onClose} title="Invite students">
    <div style={{display: "flex", justifyContent: "center", marginBottom: 18}}>
      <div className="qr"/>
    </div>
    <div style={{textAlign: "center", marginBottom: 18}}>
      <div className="tiny" style={{marginBottom: 6}}>INVITE CODE</div>
      <div style={{fontSize: 24, fontWeight: 700, fontFamily: "JetBrains Mono, monospace", letterSpacing: "0.08em", background: "var(--grad)", WebkitBackgroundClip: "text", backgroundClip: "text", color: "transparent"}}>KIMSOUL2026</div>
    </div>
    <div className="field" style={{marginBottom: 14}}>
      <label>Expiry</label>
      <select defaultValue="7"><option value="1">24 hours</option><option value="7">7 days</option><option value="30">30 days</option></select>
    </div>
    <div style={{display: "grid", gridTemplateColumns: "1fr 1fr", gap: 10, marginTop: 6}}>
      <button className="btn btn-secondary"><Icon name="share" size={16}/> Share</button>
      <button className="btn btn-secondary"><Icon name="copy" size={16}/> Copy</button>
    </div>
    <button className="btn btn-primary" style={{marginTop: 12}} onClick={onClose}>Done</button>
  </Modal>
);

const StudentDetail = ({ onBack }) => (
  <div className="scr">
    <StatusBar />
    <TopBar title="Jiwon Park" onBack={onBack} action={<button style={{background: "var(--card)", border: "1px solid var(--border)", width: 40, height: 40, borderRadius: 12, color: "var(--text-2)", display: "grid", placeItems: "center", cursor: "pointer"}}><Icon name="message" size={16}/></button>}/>

    <div className="card" style={{marginBottom: 16, padding: 18}}>
      <div style={{display: "flex", alignItems: "center", gap: 14}}>
        <div style={{width: 64, height: 64, borderRadius: 18, background: "var(--grad)", display: "grid", placeItems: "center", fontWeight: 700, fontSize: 22, color: "white"}}>JP</div>
        <div style={{flex: 1}}>
          <div style={{fontSize: 18, fontWeight: 700}}>Jiwon Park</div>
          <div style={{display: "flex", gap: 6, marginTop: 6}}>
            <span className="badge badge-yellow">Yellow Belt</span>
            <span className="badge badge-muted">Joined Mar 2026</span>
          </div>
        </div>
      </div>
    </div>

    <div className="card stack-sm" style={{marginBottom: 16}}>
      <h3 className="card-h" style={{marginBottom: 6}}>Activity</h3>
      <div style={{display: "grid", gridTemplateColumns: "1fr 1fr", gap: 10}}>
        <div style={{padding: 12, background: "rgba(255,255,255,0.03)", borderRadius: 12}}>
          <div className="tiny">FREQUENCY</div>
          <div style={{fontSize: 18, fontWeight: 700, marginTop: 4}}>2× / week</div>
        </div>
        <div style={{padding: 12, background: "rgba(255,255,255,0.03)", borderRadius: 12}}>
          <div className="tiny">LAST SESSION</div>
          <div style={{fontSize: 18, fontWeight: 700, marginTop: 4, color: "var(--primary-2)"}}>8 days ago</div>
        </div>
      </div>
    </div>

    <div className="card stack-sm" style={{marginBottom: 16}}>
      <h3 className="card-h" style={{marginBottom: 6}}>Patterns & weak points</h3>
      <div style={{fontSize: 12, color: "var(--text-2)", marginBottom: 6}}>Analyzed: Chon-Ji, Dan-Gun</div>
      {[
        {n: "Chon-Ji M1 · stance depth", s: "crit", c: 5},
        {n: "Chon-Ji M3 · L-stance", s: "impr", c: 3},
      ].map((w, i) => (
        <div key={i} style={{display: "flex", alignItems: "center", gap: 10, padding: "8px 0", borderTop: i ? "1px solid var(--border)" : "none"}}>
          <span className={`sev sev-${w.s}`} style={{minWidth: 56, textAlign: "center"}}>×{w.c}</span>
          <div style={{flex: 1, fontSize: 13}}>{w.n}</div>
        </div>
      ))}
    </div>

    <div className="card stack-sm" style={{marginBottom: 16}}>
      <h3 className="card-h" style={{marginBottom: 6}}>Homework</h3>
      <div className="card-row" style={{padding: "8px 0"}}><div style={{fontSize: 13}}>Practice low block 100x</div><span className="badge badge-green">Done</span></div>
      <div className="card-row" style={{padding: "8px 0", borderTop: "1px solid var(--border)"}}><div style={{fontSize: 13}}>Submit Chon-Ji M1 analysis</div><span className="badge badge-yellow">Pending</span></div>
    </div>

    <div className="stack-sm">
      <button className="btn btn-primary"><Icon name="message" size={16}/> Send comment</button>
      <button className="btn btn-secondary"><Icon name="plus" size={16}/> Assign homework</button>
      <button className="btn btn-destructive"><Icon name="trash" size={16}/> Remove from dojang</button>
    </div>
  </div>
);

Object.assign(window, { DojangMain, InviteModal, StudentDetail });
