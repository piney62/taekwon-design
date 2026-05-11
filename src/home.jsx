// Home screens (Student + Instructor)
const StudentHome = ({ navigate, openModal }) => (
  <div className="scr">
    <StatusBar />
    <div style={{display: "flex", justifyContent: "space-between", alignItems: "flex-start", marginBottom: 22, marginTop: 4}}>
      <div>
        <div style={{display: "flex", alignItems: "center", gap: 8, marginBottom: 12}}>
          <div style={{width: 28, height: 28, borderRadius: 8, background: "var(--grad)", display: "grid", placeItems: "center"}}>
            <Icon name="flame" size={14} stroke="white"/>
          </div>
          <span style={{fontSize: 12, color: "var(--text-2)"}}>ITF TulMaster</span>
        </div>
        <h1 className="title" style={{margin: 0}}>Welcome back,</h1>
        <h1 className="title"><span className="accent">Nick!</span></h1>
      </div>
      <button onClick={() => navigate("me")} style={{width: 44, height: 44, borderRadius: 14, background: "var(--card)", border: "1px solid var(--border)", color: "var(--text)", display: "grid", placeItems: "center", cursor: "pointer"}}>
        <Icon name="settings" size={18}/>
      </button>
    </div>

    <div className="stats-grid" style={{marginBottom: 20}}>
      <StatCard icon="flame" value="10" label="Day Streak" color="primary"/>
      <StatCard icon="target" value="70%" label="Belt Progress" color="secondary"/>
      <StatCard icon="trending" value="15" label="This Month" color="accent"/>
    </div>

    <div style={{marginBottom: 20}}>
      <FeatureCard
        label="Today's Focus"
        title="Chon-Ji Pattern (천지)"
        body="Practice movements 1-5 · Focus on stance and balance"
        primaryLabel="Start Training"
        secondaryLabel="View Details"
        onPrimary={() => navigate("analyze")}
        onSecondary={() => navigate("patternDetail")}
      />
    </div>

    <div className="card stack-sm" style={{marginBottom: 20}}>
      <div className="card-row">
        <h3 className="card-h">Sabum's Homework</h3>
        <span className="badge badge-muted">2 tasks</span>
      </div>
      {[
        {t: "Practice low block technique", s: "Due in 3 days"},
        {t: "Analyze Chon-Ji movements 10-15", s: "Due in 5 days"}
      ].map((hw, i) => (
        <label key={i} style={{display: "flex", alignItems: "flex-start", gap: 12, padding: 14, background: "rgba(255,255,255,0.03)", borderRadius: 14, cursor: "pointer"}}>
          <input type="checkbox" style={{width: 18, height: 18, marginTop: 2, accentColor: "var(--primary)"}}/>
          <div style={{flex: 1}}>
            <div style={{fontSize: 13, fontWeight: 500, marginBottom: 2}}>{hw.t}</div>
            <div className="tiny">{hw.s}</div>
          </div>
        </label>
      ))}
    </div>

    <div className="card stack-sm" style={{marginBottom: 20}}>
      <h3 className="card-h" style={{marginBottom: 6}}>This Week</h3>
      <div style={{display: "grid", gridTemplateColumns: "repeat(7, 1fr)", gap: 6}}>
        {["M","T","W","T","F","S","S"].map((d, i) => {
          const filled = [0,1,2,4].includes(i);
          return (
            <div key={i} style={{display: "flex", flexDirection: "column", alignItems: "center", gap: 6}}>
              <div className="tiny">{d}</div>
              <div style={{width: "100%", aspectRatio: 1, borderRadius: 10, background: filled ? "var(--grad)" : "rgba(255,255,255,0.05)", display: "grid", placeItems: "center"}}>
                {filled && <Icon name="check" size={12} stroke="white"/>}
              </div>
            </div>
          );
        })}
      </div>
    </div>

    <div className="card stack-sm">
      <div className="card-row" style={{marginBottom: 8}}>
        <h3 className="card-h">Recent Activity</h3>
        <button className="btn-ghost" style={{padding: 0, fontSize: 12, background: "transparent", border: 0, color: "var(--primary)", cursor: "pointer"}}>View all</button>
      </div>
      <ListRow icon="target" iconColor="primary" title="Chon-Ji Analysis" sub="Today · 68% accuracy" right={<span style={{color: "var(--primary)", fontSize: 13, fontWeight: 600}}>+5</span>} onClick={() => navigate("analyzeResult")}/>
      <ListRow icon="trending" iconColor="secondary" title="Training Session" sub="Yesterday · 45 min" right={<span style={{color: "var(--secondary)", fontSize: 13, fontWeight: 600}}>+8</span>}/>
    </div>
  </div>
);

const InstructorHome = ({ navigate }) => (
  <div className="scr">
    <StatusBar />
    <div style={{display: "flex", justifyContent: "space-between", alignItems: "flex-start", marginBottom: 22, marginTop: 4}}>
      <div>
        <div style={{display: "flex", alignItems: "center", gap: 8, marginBottom: 12}}>
          <div style={{width: 28, height: 28, borderRadius: 8, background: "linear-gradient(135deg, #3b82f6, #8b5cf6)", display: "grid", placeItems: "center"}}>
            <Icon name="award" size={14} stroke="white"/>
          </div>
          <span style={{fontSize: 12, color: "var(--text-2)"}}>Sabum · 3rd Dan</span>
        </div>
        <h1 className="title" style={{margin: 0}}>Good morning,</h1>
        <h1 className="title"><span className="accent">Master Kim</span></h1>
      </div>
      <button onClick={() => navigate("me")} style={{width: 44, height: 44, borderRadius: 14, background: "var(--card)", border: "1px solid var(--border)", color: "var(--text)", display: "grid", placeItems: "center", cursor: "pointer"}}>
        <Icon name="settings" size={18}/>
      </button>
    </div>

    <div className="card stack-sm" style={{marginBottom: 20, borderColor: "rgba(239,68,68,0.3)", background: "linear-gradient(135deg, rgba(239,68,68,0.08), var(--card))"}}>
      <div className="card-row">
        <div style={{display: "flex", alignItems: "center", gap: 10}}>
          <Icon name="alert" size={18} stroke="var(--primary)"/>
          <h3 className="card-h">Needs Attention</h3>
        </div>
        <span className="badge badge-red">3</span>
      </div>
      <ListRow icon="user" iconColor="primary" title="Jiwon Park" sub="No training in 8 days · Yellow Belt"/>
      <ListRow icon="user" iconColor="primary" title="Alex Chen" sub="Repeated weak stance on Chon-Ji M3"/>
      <ListRow icon="user" iconColor="primary" title="Sara Lee" sub="Homework overdue · 2 days"/>
    </div>

    <div className="stats-grid" style={{marginBottom: 20}}>
      <StatCard icon="users" value="12" label="Trained today" color="primary"/>
      <StatCard icon="flame" value="4" label="Idle students" color="secondary"/>
      <StatCard icon="alert" value="6" label="Pending HW" color="accent"/>
    </div>

    <div style={{display: "grid", gridTemplateColumns: "1fr 1fr", gap: 10, marginBottom: 20}}>
      <button className="btn btn-primary" style={{padding: "16px 12px", fontSize: 13}} onClick={() => navigate("dojang")}><Icon name="plus" size={16}/> Assign HW</button>
      <button className="btn btn-secondary" style={{padding: "16px 12px", fontSize: 13}} onClick={() => navigate("inviteModal")}><Icon name="qr" size={16}/> Invite</button>
    </div>

    <div className="card stack-sm" style={{marginBottom: 20}}>
      <div className="card-row" style={{marginBottom: 6}}>
        <h3 className="card-h">Pending Reviews</h3>
        <span className="badge badge-muted">4 waiting</span>
      </div>
      <ListRow icon="scan" iconColor="secondary" title="Jiwon · Chon-Ji M5" sub="Submitted 2h ago" onClick={() => navigate("studentDetail")}/>
      <ListRow icon="scan" iconColor="secondary" title="Alex · Dan-Gun M12" sub="Submitted yesterday" onClick={() => navigate("studentDetail")}/>
      <ListRow icon="scan" iconColor="secondary" title="Sara · Do-San M2" sub="Submitted 2 days ago" onClick={() => navigate("studentDetail")}/>
    </div>

    <div className="card">
      <div className="card-row" style={{marginBottom: 14}}>
        <h3 className="card-h">Dojang Snapshot</h3>
        <button className="btn-ghost" style={{padding: 0, fontSize: 12, background: "transparent", border: 0, color: "var(--primary)", cursor: "pointer"}} onClick={() => navigate("dojang")}>Open</button>
      </div>
      <div style={{display: "grid", gridTemplateColumns: "1fr 1fr", gap: 10}}>
        <div style={{padding: 14, background: "rgba(255,255,255,0.03)", borderRadius: 14}}>
          <div style={{fontSize: 24, fontWeight: 700}}>28</div>
          <div className="tiny">Total students</div>
        </div>
        <div style={{padding: 14, background: "rgba(255,255,255,0.03)", borderRadius: 14}}>
          <div style={{fontSize: 24, fontWeight: 700, background: "var(--grad)", WebkitBackgroundClip: "text", backgroundClip: "text", color: "transparent"}}>78%</div>
          <div className="tiny">Weekly activity</div>
        </div>
      </div>
    </div>
  </div>
);

Object.assign(window, { StudentHome, InstructorHome });
