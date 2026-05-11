// Journal screens — main, add training modal, all records, weak points, belt progress
const JournalMain = ({ navigate, openModal }) => {
  const days = Array.from({length: 31}, (_, i) => i + 1);
  const trainingDays = [2, 5, 8, 12, 15, 18, 22, 25, 28];
  const today = 12;
  return (
    <div className="scr">
      <StatusBar />
      <div style={{display: "flex", alignItems: "flex-start", justifyContent: "space-between"}}>
        <div>
          <h1 className="title">Training <span className="accent">Journal</span></h1>
          <p className="subtitle">Track progress and ITF belt advancement.</p>
        </div>
        <span className="badge badge-blue" style={{marginTop: 18}}><Icon name="building" size={10}/> Master Kim's</span>
      </div>

      <div className="stats-grid" style={{marginBottom: 20}}>
        <StatCard icon="flame" value="10" label="days streak" color="primary"/>
        <StatCard icon="trending" value="15" label="this month" color="secondary"/>
        <StatCard icon="target" value="2" label="pending HW" color="accent"/>
      </div>

      <div className="card stack-sm" style={{marginBottom: 18}}>
        <div className="card-row">
          <h3 className="card-h">Sabum's Homework</h3>
          <span className="badge badge-muted">2 tasks</span>
        </div>
        {[
          {t: "Practice low block", s: "Due in 3 days", c: false},
          {t: "Analyze Chon-Ji M10-15", s: "Due in 5 days", c: false}
        ].map((hw, i) => (
          <label key={i} style={{display: "flex", alignItems: "center", gap: 12, padding: 12, background: "rgba(255,255,255,0.03)", borderRadius: 12, cursor: "pointer"}}>
            <input type="checkbox" defaultChecked={hw.c} style={{width: 18, height: 18, accentColor: "var(--primary)"}}/>
            <div style={{flex: 1}}>
              <div style={{fontSize: 13, fontWeight: 500}}>{hw.t}</div>
              <div className="tiny">{hw.s}</div>
            </div>
          </label>
        ))}
      </div>

      <div className="card" style={{marginBottom: 18, cursor: "pointer"}} onClick={() => navigate("beltProgress")}>
        <div className="card-row" style={{marginBottom: 14}}>
          <h3 className="card-h">Belt Progress</h3>
          <Icon name="chevron" size={16} stroke="var(--text-3)"/>
        </div>
        <div style={{display: "flex", alignItems: "center", gap: 18}}>
          <ProgressRing value={70} size={88} stroke={8}/>
          <div style={{flex: 1}}>
            <div style={{fontSize: 12, color: "var(--text-3)", marginBottom: 4}}>NEXT BELT</div>
            <div style={{fontSize: 16, fontWeight: 700, marginBottom: 8}}>Yellow → Green</div>
            <div className="tiny">3 of 5 criteria met</div>
          </div>
        </div>
      </div>

      <div className="card" style={{marginBottom: 18, cursor: "pointer"}} onClick={() => navigate("weakPoints")}>
        <div className="card-row" style={{marginBottom: 12}}>
          <h3 className="card-h">Weak Points</h3>
          <Icon name="chevron" size={16} stroke="var(--text-3)"/>
        </div>
        {[
          {n: "Chon-Ji M1 · low block", c: 4, s: "crit"},
          {n: "Chon-Ji M3 · L-stance", c: 3, s: "impr"},
          {n: "Dan-Gun M7 · hip rotation", c: 2, s: "watch"}
        ].map((w, i) => (
          <div key={i} style={{display: "flex", alignItems: "center", gap: 10, padding: "10px 0", borderTop: i ? "1px solid var(--border)" : "none"}}>
            <span className={`sev sev-${w.s}`} style={{minWidth: 56, textAlign: "center"}}>×{w.c}</span>
            <div style={{flex: 1, fontSize: 13}}>{w.n}</div>
          </div>
        ))}
      </div>

      <div className="card" style={{marginBottom: 18}}>
        <div className="card-row" style={{marginBottom: 18}}>
          <h3 className="card-h">May 2026</h3>
          <Icon name="cal" size={16} stroke="var(--text-3)"/>
        </div>
        <div className="cal-grid" style={{marginBottom: 6}}>
          {["M","T","W","T","F","S","S"].map((d, i) => <div key={i} className={`cal-h ${i>=5?"weekend":""}`}>{d}</div>)}
        </div>
        <div className="cal-grid">
          {days.map(d => {
            const t = trainingDays.includes(d);
            const isToday = d === today;
            return <div key={d} className={`cal-day ${t && !isToday ? "train" : ""} ${isToday ? "today" : ""}`}>{d}</div>;
          })}
        </div>
      </div>

      <button className="btn-dashed" style={{marginBottom: 18}} onClick={openModal}>
        <Icon name="plus" size={18}/> Add Training Session
      </button>

      <div className="card">
        <div className="card-row" style={{marginBottom: 14}}>
          <h3 className="card-h">Recent Records</h3>
          <button className="btn-ghost" style={{padding: 0, fontSize: 12, background: "transparent", border: 0, color: "var(--primary)", cursor: "pointer"}}>View all</button>
        </div>
        <ListRow icon="target" iconColor="primary" title="Chon-Ji Pattern" sub="45 min · 6 movements" right={<span style={{color: "var(--primary)", fontSize: 13, fontWeight: 600}}>68%</span>}/>
        <ListRow icon="trending" iconColor="secondary" title="Sparring Practice" sub="30 min · 3 rounds" right={<span style={{color: "var(--secondary)", fontSize: 13, fontWeight: 600}}>85%</span>}/>
        <ListRow icon="target" iconColor="accent" title="Dan-Gun Pattern" sub="38 min · 8 movements" right={<span style={{color: "var(--accent)", fontSize: 13, fontWeight: 600}}>74%</span>}/>
      </div>
    </div>
  );
};

const AddTrainingModal = ({ onClose }) => {
  const [stars, setStars] = React.useState(4);
  return (
    <Modal onClose={onClose} title="Add Training Session">
      <div className="stack-md">
        <div className="field"><label>Date</label><input type="date" defaultValue="2026-05-12"/></div>
        <div className="field">
          <label>Training type</label>
          <select defaultValue="pattern">
            <option value="pattern">Pattern</option>
            <option value="sparring">Sparring</option>
            <option value="breaking">Breaking</option>
            <option value="other">Other</option>
          </select>
        </div>
        <div className="field">
          <label>Pattern</label>
          <select defaultValue="chon-ji">
            <option value="chon-ji">Chon-Ji (천지)</option>
            <option value="dan-gun">Dan-Gun (단군)</option>
            <option value="do-san">Do-San (도산)</option>
          </select>
        </div>
        <div className="field"><label>Duration (minutes)</label><input type="number" defaultValue="45"/></div>
        <div className="field">
          <label>Self rating</label>
          <div className="stars">
            {[1,2,3,4,5].map(n => (
              <button key={n} className={n <= stars ? "on" : ""} onClick={() => setStars(n)}>
                <Icon name="star" size={26} fill={n <= stars ? "currentColor" : "none"}/>
              </button>
            ))}
          </div>
        </div>
        <div className="field"><label>Memo</label><textarea rows="3" defaultValue="Focused on stance depth. Need to work on hip rotation in M3."/></div>
      </div>
      <div style={{display: "flex", gap: 10, marginTop: 22}}>
        <button className="btn btn-secondary" onClick={onClose}>Cancel</button>
        <button className="btn btn-primary" onClick={onClose}>Save</button>
      </div>
    </Modal>
  );
};

const WeakPointsDetail = ({ onBack, navigate }) => (
  <div className="scr">
    <StatusBar />
    <TopBar title="Weak Points" onBack={onBack}/>
    <div className="card" style={{marginBottom: 16, background: "var(--grad-soft)", borderColor: "rgba(239,68,68,0.2)"}}>
      <div style={{display: "flex", gap: 12}}>
        <Icon name="info" size={20} stroke="var(--primary-2)"/>
        <div style={{flex: 1, fontSize: 12, color: "var(--text-2)", lineHeight: 1.55}}>
          Movements that scored low on 2+ consecutive analyses are tracked here. Tap one to retry it with the analyzer pre-filled.
        </div>
      </div>
    </div>

    <div className="stack-sm">
      {[
        {n: "Walking stance low block", p: "Chon-Ji M1", sev: "crit", tag: "Critical", c: 4, d: "First detected May 2"},
        {n: "L-stance inner forearm", p: "Chon-Ji M3", sev: "impr", tag: "Needs Improvement", c: 3, d: "First detected May 5"},
        {n: "Hip rotation on block", p: "Dan-Gun M7", sev: "impr", tag: "Needs Improvement", c: 3, d: "First detected May 7"},
        {n: "High block follow-through", p: "Do-San M2", sev: "watch", tag: "Watch", c: 2, d: "First detected May 8"}
      ].map((w, i) => (
        <div key={i} className="card compact" style={{cursor: "pointer"}} onClick={() => navigate("analyze")}>
          <div className="card-row" style={{marginBottom: 8}}>
            <span className={`sev sev-${w.sev}`}>{w.tag}</span>
            <span className="badge badge-muted">×{w.c} consecutive</span>
          </div>
          <div style={{fontSize: 15, fontWeight: 600, marginBottom: 4}}>{w.n}</div>
          <div className="tiny" style={{marginBottom: 8}}>{w.p}</div>
          <div className="micro">{w.d}</div>
        </div>
      ))}
    </div>
  </div>
);

const BeltProgressDetail = ({ onBack }) => (
  <div className="scr">
    <StatusBar />
    <TopBar title="Belt Progress" onBack={onBack}/>
    <div style={{display: "flex", flexDirection: "column", alignItems: "center", marginBottom: 22}}>
      <ProgressRing value={70} size={160} stroke={14}/>
      <div className="tiny" style={{marginTop: 12}}>TO</div>
      <div style={{fontSize: 22, fontWeight: 700, marginTop: 4, background: "var(--grad)", WebkitBackgroundClip: "text", backgroundClip: "text", color: "transparent"}}>Green Belt (초록띠)</div>
    </div>

    <h3 className="card-h" style={{marginBottom: 12}}>Readiness checklist</h3>
    <div className="stack-sm" style={{marginBottom: 22}}>
      {[
        {t: "Training duration (40h)", s: "38h / 40h", done: false, p: 95},
        {t: "Pattern analyses (20)", s: "23 / 20", done: true},
        {t: "Pattern quality avg ≥ 70%", s: "72%", done: true},
        {t: "Sparring evaluation by sabum", s: "Pending", done: false, pending: true},
        {t: "Breaking evaluation (optional)", s: "Not started", done: false, opt: true}
      ].map((it, i) => (
        <div key={i} className="card compact" style={{padding: 14}}>
          <div className="card-row">
            <div style={{display: "flex", alignItems: "center", gap: 12}}>
              <div style={{width: 26, height: 26, borderRadius: 8, background: it.done ? "var(--green)" : it.pending ? "rgba(250,204,21,0.15)" : "rgba(255,255,255,0.06)", display: "grid", placeItems: "center", color: it.done ? "white" : it.pending ? "var(--yellow)" : "var(--text-3)"}}>
                {it.done ? <Icon name="check" size={14}/> : it.pending ? "…" : it.opt ? "?" : <Icon name="flame" size={12}/>}
              </div>
              <div>
                <div style={{fontSize: 13, fontWeight: 500}}>{it.t}</div>
                <div className="tiny">{it.s}</div>
              </div>
            </div>
          </div>
        </div>
      ))}
    </div>

    <div className="card" style={{marginBottom: 18, background: "var(--grad-soft)"}}>
      <div style={{fontSize: 13, color: "var(--text)", lineHeight: 1.55}}>
        <b>Almost there.</b> 2 more training hours and a sparring evaluation will put you ready for promotion.
      </div>
    </div>

    <button className="btn btn-primary"><Icon name="bolt" size={16}/> Take Theory Test</button>
  </div>
);

const AllRecords = ({ onBack, openModal }) => (
  <div className="scr">
    <StatusBar />
    <TopBar title="All Records" onBack={onBack} action={<button onClick={openModal} style={{background: "var(--grad)", border: 0, width: 40, height: 40, borderRadius: 12, color: "white", display: "grid", placeItems: "center", cursor: "pointer"}}><Icon name="plus" size={18}/></button>}/>
    <div className="chips-row" style={{marginBottom: 14}}>
      <button className="chip on">All</button>
      <button className="chip">Pattern</button>
      <button className="chip">Sparring</button>
      <button className="chip">Breaking</button>
      <button className="chip">Auto-saved</button>
    </div>
    <div className="stack-sm">
      {[
        {p: "Chon-Ji Pattern", d: "Today · 45m", r: 4, c: "Stance depth needs work"},
        {p: "Sparring Practice", d: "Yesterday · 30m", r: 5, c: "Great rhythm — Sabum"},
        {p: "Dan-Gun Pattern", d: "May 10 · 38m", r: 4, c: null},
        {p: "Chon-Ji Pattern", d: "May 8 · 50m", r: 3, c: null},
        {p: "Breaking Drill", d: "May 5 · 22m", r: 4, c: null}
      ].map((r, i) => (
        <div key={i} className="card compact" style={{padding: 14}}>
          <div className="card-row" style={{marginBottom: 6}}>
            <div style={{fontSize: 14, fontWeight: 600}}>{r.p}</div>
            <div style={{display: "flex", gap: 6}}>
              <Icon name="edit" size={14} stroke="var(--text-3)"/>
              <Icon name="trash" size={14} stroke="var(--text-3)"/>
            </div>
          </div>
          <div className="tiny" style={{marginBottom: 8}}>{r.d}</div>
          <div className="stars" style={{marginBottom: r.c ? 8 : 0}}>
            {[1,2,3,4,5].map(n => <span key={n} style={{color: n <= r.r ? "var(--yellow)" : "var(--text-3)"}}><Icon name="star" size={14} fill={n <= r.r ? "currentColor" : "none"}/></span>)}
          </div>
          {r.c && <div style={{fontSize: 11, color: "var(--secondary-2)", background: "rgba(59,130,246,0.08)", padding: "6px 10px", borderRadius: 8, marginTop: 4}}>{r.c}</div>}
        </div>
      ))}
    </div>
  </div>
);

Object.assign(window, { JournalMain, AddTrainingModal, WeakPointsDetail, BeltProgressDetail, AllRecords });
