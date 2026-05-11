// Me / profile screens
const MeScreen = ({ navigate, role, openLogoutModal }) => (
  <div className="scr">
    <StatusBar />
    <h1 className="title">Profile</h1>
    <p className="subtitle">Manage your <span className="ko">ITF Taekwon-Do</span> journey</p>

    <div className="card" style={{marginBottom: 16, padding: 20}}>
      <div style={{display: "flex", alignItems: "center", gap: 14, marginBottom: 16}}>
        <div style={{width: 72, height: 72, borderRadius: 20, background: "var(--grad)", display: "grid", placeItems: "center", position: "relative", boxShadow: "0 12px 30px rgba(239,68,68,0.3)"}}>
          <Icon name="user" size={32} stroke="white"/>
          <div style={{position: "absolute", bottom: -4, right: -4, width: 28, height: 28, borderRadius: 10, background: role === "instructor" ? "linear-gradient(135deg, #3b82f6, #8b5cf6)" : "linear-gradient(135deg, #facc15, #f59e0b)", border: "3px solid var(--stage)", display: "grid", placeItems: "center"}}>
            <Icon name="award" size={12} stroke="white"/>
          </div>
        </div>
        <div style={{flex: 1}}>
          <div style={{fontSize: 18, fontWeight: 700, marginBottom: 8}}>{role === "instructor" ? "Master Kim" : "Nick Anderson"}</div>
          <div style={{display: "flex", gap: 6, flexWrap: "wrap"}}>
            <span className="badge badge-red">{role === "instructor" ? "Instructor" : "ITF Student"}</span>
            <span className="badge badge-blue">{role === "instructor" ? "3rd Dan (삼단)" : "Yellow Belt (노란띠)"}</span>
          </div>
        </div>
      </div>
      <button className="btn btn-secondary" onClick={() => navigate("editProfile")}>Edit Profile</button>
    </div>

    <div className="card" style={{marginBottom: 16, padding: 16}}>
      <h3 className="card-h" style={{margin: "0 0 10px", padding: "0 4px"}}>Account</h3>
      <ListRow icon="shield" iconColor="primary" title="Change Password" sub="Last changed Jan 2026" onClick={() => navigate("changePassword")}/>
    </div>

    <div className="card" style={{marginBottom: 16, padding: 16}}>
      <h3 className="card-h" style={{margin: "0 0 10px", padding: "0 4px"}}>Preferences</h3>
      <ListRow icon="moon" iconColor="secondary" title="Theme" sub="Appearance" right={<div style={{display: "flex", alignItems: "center", gap: 4, color: "var(--text-3)"}}><span style={{fontSize: 13}}>Dark</span><Icon name="chevron" size={16}/></div>}/>
      <ListRow icon="globe" iconColor="accent" title="Language" sub="App language" right={<div style={{display: "flex", alignItems: "center", gap: 4, color: "var(--text-3)"}}><span style={{fontSize: 13}}>English</span><Icon name="chevron" size={16}/></div>}/>
    </div>

    <div className="card" style={{marginBottom: 16, background: "var(--grad-soft)", borderColor: "rgba(239,68,68,0.2)"}}>
      <div style={{display: "flex", alignItems: "center", gap: 14}}>
        <div style={{width: 48, height: 48, borderRadius: 14, background: "var(--grad)", display: "grid", placeItems: "center", flexShrink: 0}}>
          <Icon name="building" size={22} stroke="white"/>
        </div>
        <div style={{flex: 1}}>
          <div style={{fontSize: 14, fontWeight: 600, marginBottom: 3}}>Master Kim's Dojang</div>
          <div className="tiny" style={{marginBottom: 6}}>ITF Seoul Chapter · Joined Oct 2023</div>
          <span className="badge badge-red">Active Member</span>
        </div>
      </div>
    </div>

    <div className="card" style={{marginBottom: 18, padding: 16}}>
      <h3 className="card-h" style={{margin: "0 0 10px", padding: "0 4px"}}>About</h3>
      <ListRow icon="info" iconColor="primary" title="Terms & Privacy" sub="Read the fine print"/>
      <ListRow icon="info" iconColor="secondary" title="Support" sub="Get help · contact us"/>
      <div style={{padding: "10px 4px 2px"}}>
        <div className="tiny" style={{fontFamily: "JetBrains Mono, monospace"}}>TulMaster v1.0.0 · ITF Edition</div>
      </div>
    </div>

    <button className="btn btn-destructive" onClick={openLogoutModal}><Icon name="logout" size={16}/> Logout</button>
  </div>
);

const EditProfileModal = ({ onClose }) => (
  <Modal onClose={onClose} title="Edit Profile">
    <div style={{display: "flex", justifyContent: "center", marginBottom: 18}}>
      <div style={{position: "relative"}}>
        <div style={{width: 88, height: 88, borderRadius: 24, background: "var(--grad)", display: "grid", placeItems: "center"}}>
          <Icon name="user" size={36} stroke="white"/>
        </div>
        <button style={{position: "absolute", bottom: -4, right: -4, width: 32, height: 32, borderRadius: 12, background: "var(--card)", border: "2px solid var(--stage)", color: "var(--text)", cursor: "pointer", display: "grid", placeItems: "center"}}><Icon name="camera" size={14}/></button>
      </div>
    </div>
    <div className="stack-md">
      <div className="field"><label>Display name</label><input defaultValue="Nick Anderson"/></div>
    </div>
    <div style={{display: "flex", gap: 10, marginTop: 22}}>
      <button className="btn btn-secondary" onClick={onClose}>Cancel</button>
      <button className="btn btn-primary" onClick={onClose}>Save</button>
    </div>
  </Modal>
);

const ChangePasswordModal = ({ onClose }) => (
  <Modal onClose={onClose} title="Change Password">
    <div className="stack-md">
      <div className="field"><label>Current password</label><input type="password" defaultValue="••••••••"/></div>
      <div className="field"><label>New password</label><input type="password" placeholder="At least 8 characters"/></div>
      <div className="field"><label>Confirm new password</label><input type="password"/></div>
    </div>
    <div style={{display: "flex", gap: 10, marginTop: 22}}>
      <button className="btn btn-secondary" onClick={onClose}>Cancel</button>
      <button className="btn btn-primary" onClick={onClose}>Save</button>
    </div>
  </Modal>
);

Object.assign(window, { MeScreen, EditProfileModal, ChangePasswordModal });
