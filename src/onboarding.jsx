// Onboarding flow screens
const { useState: useStateOn } = React;

const SplashScreen = ({ onContinue }) => (
  <div className="splash-stage">
    <div className="splash-mark">
      <svg viewBox="0 0 24 24" fill="none" strokeWidth="2.4" strokeLinecap="round" strokeLinejoin="round"><path d="M8 2v4M16 2v4M12 14l-3 3 1 5 4-2 4 2 1-5-3-3"/><circle cx="12" cy="9" r="3"/></svg>
    </div>
    <h1 className="splash-title">TulMaster</h1>
    <div className="splash-tag">Master Every Pattern.</div>
    <div className="splash-foot">
      <span className="on"/><span/><span/>
    </div>
    <button className="btn btn-primary" style={{position: "absolute", bottom: 100, left: 28, right: 28, width: "auto"}} onClick={onContinue}>Continue</button>
  </div>
);

const WelcomeScreen = ({ goRole, goLogin }) => (
  <div className="splash-stage" style={{padding: "40px 28px", justifyContent: "flex-end"}}>
    <div style={{position: "absolute", top: 80, left: 0, right: 0, display: "flex", flexDirection: "column", alignItems: "center"}}>
      <div className="splash-mark" style={{width: 64, height: 64, borderRadius: 18, marginBottom: 18}}>
        <svg viewBox="0 0 24 24" width="32" height="32" fill="none" stroke="white" strokeWidth="2.4" strokeLinecap="round" strokeLinejoin="round"><path d="M8 2v4M16 2v4M12 14l-3 3 1 5 4-2 4 2 1-5-3-3"/><circle cx="12" cy="9" r="3"/></svg>
      </div>
      <h1 style={{fontSize: 28, margin: 0, fontWeight: 700}}>Welcome to TulMaster</h1>
      <p style={{fontSize: 14, color: "var(--text-2)", textAlign: "center", margin: "10px 28px 0", lineHeight: 1.55}}>
        Your digital training companion for ITF Taekwon-Do.<br/>Track patterns, get pose feedback, grow your belt.
      </p>
    </div>
    <div style={{width: "100%", display: "flex", flexDirection: "column", gap: 12, marginBottom: 30}}>
      <button className="btn btn-primary" onClick={goRole}>Get Started</button>
      <button className="btn btn-ghost" onClick={goLogin} style={{width: "100%"}}>Already have an account? <span style={{color: "var(--primary)", marginLeft: 4}}>Sign in</span></button>
    </div>
  </div>
);

const RoleScreen = ({ role, setRole, onBack, onNext }) => (
  <div className="scr">
    <StatusBar />
    <div className="steps"><div className="step on"/><div className="step"/><div className="step"/><span className="lbl">STEP 1 / 3</span></div>
    <h1 className="title">Choose your <span className="accent">role</span></h1>
    <p className="subtitle">This shapes your home screen and tools.</p>

    <div className="stack-md">
      <div className={`role-card ${role === "student" ? "on" : ""}`} onClick={() => setRole("student")}>
        <div className="role-icon"><Icon name="user" size={26} stroke="var(--primary)"/></div>
        <h3>Student</h3>
        <p>Train daily, analyze your patterns, and track your belt journey.</p>
      </div>
      <div className={`role-card ${role === "instructor" ? "on" : ""}`} onClick={() => setRole("instructor")}>
        <div className="role-icon"><Icon name="users" size={26} stroke="var(--secondary)"/></div>
        <h3>Instructor (Sabum)</h3>
        <p>Manage your dojang, assign homework, and review student progress.</p>
      </div>
    </div>

    <div style={{display: "flex", gap: 10, marginTop: 32}}>
      <button className="btn btn-secondary" onClick={onBack}>Back</button>
      <button className="btn btn-primary" onClick={onNext}>Continue</button>
    </div>
  </div>
);

const AccountScreen = ({ onBack, onNext }) => {
  const [show, setShow] = useStateOn(false);
  return (
    <div className="scr">
      <StatusBar />
      <div className="steps"><div className="step on"/><div className="step on"/><div className="step"/><span className="lbl">STEP 2 / 3</span></div>
      <h1 className="title">Create your <span className="accent">account</span></h1>
      <p className="subtitle">You can change these anytime in Settings.</p>

      <div className="stack-md">
        <div className="field"><label>Username</label><input defaultValue="nick.anderson"/><div className="helper">Letters, numbers and dots.</div></div>
        <div className="field"><label>Display name</label><input defaultValue="Nick Anderson"/></div>
        <div className="field">
          <label>Password</label>
          <div style={{position: "relative"}}>
            <input type={show ? "text" : "password"} defaultValue="••••••••" style={{paddingRight: 44}}/>
            <button onClick={() => setShow(!show)} style={{position: "absolute", right: 12, top: 12, background: "transparent", border: 0, color: "var(--text-2)", cursor: "pointer"}}><Icon name={show ? "eye" : "eyeOff"} size={18}/></button>
          </div>
        </div>
        <div className="field field-success"><label>Confirm password</label><input type="password" defaultValue="••••••••"/><div className="helper" style={{color: "var(--green)"}}>✓ Passwords match.</div></div>
      </div>

      <div style={{display: "flex", gap: 10, marginTop: 28}}>
        <button className="btn btn-secondary" onClick={onBack}>Back</button>
        <button className="btn btn-primary" onClick={onNext}>Continue</button>
      </div>
    </div>
  );
};

const ProfileSetupScreen = ({ role, onBack, onFinish }) => (
  <div className="scr">
    <StatusBar />
    <div className="steps"><div className="step on"/><div className="step on"/><div className="step on"/><span className="lbl">STEP 3 / 3</span></div>
    <h1 className="title">Set up your <span className="accent">profile</span></h1>
    <p className="subtitle">{role === "instructor" ? "Tell us about your dojang." : "Tell us where you are on the belt path."}</p>

    {role === "instructor" ? (
      <div className="stack-md">
        <div className="field"><label>Dojang name</label><input defaultValue="Master Kim's Dojang"/></div>
        <div className="field">
          <label>Dan grade</label>
          <select defaultValue="3">
            <option value="1">1st Dan (초단)</option>
            <option value="2">2nd Dan (이단)</option>
            <option value="3">3rd Dan (삼단)</option>
            <option value="4">4th Dan (사단)</option>
          </select>
        </div>
        <div className="field"><label>Years teaching</label><input defaultValue="8" type="number"/></div>
      </div>
    ) : (
      <div className="stack-md">
        <div className="field">
          <label>Current belt</label>
          <select defaultValue="yellow">
            <option value="white">White Belt (흰띠)</option>
            <option value="yellow">Yellow Belt (노란띠)</option>
            <option value="green">Green Belt (초록띠)</option>
            <option value="blue">Blue Belt (파란띠)</option>
            <option value="red">Red Belt (빨간띠)</option>
          </select>
        </div>
        <div className="field"><label>Dojang invite code <span style={{color: "var(--text-3)"}}>· optional</span></label><input placeholder="e.g. KIMSOUL2026" defaultValue="KIMSOUL2026"/></div>
        <div className="card compact" style={{padding: 14, background: "var(--grad-soft)", border: "1px solid rgba(239,68,68,0.2)"}}>
          <div className="card-row">
            <Icon name="building" size={18} stroke="var(--primary)"/>
            <div style={{flex: 1, fontSize: 12, color: "var(--text)"}}>Will connect to <b>Master Kim's Dojang</b> · ITF Seoul Chapter</div>
            <span className="badge badge-green"><Icon name="check" size={10}/> Valid</span>
          </div>
        </div>
      </div>
    )}

    <div style={{display: "flex", gap: 10, marginTop: 28}}>
      <button className="btn btn-secondary" onClick={onBack}>Back</button>
      <button className="btn btn-primary" onClick={onFinish}>Start training</button>
    </div>
  </div>
);

const LoginScreen = ({ onBack, onLogin }) => (
  <div className="scr">
    <StatusBar />
    <TopBar title="Sign in" onBack={onBack}/>
    <div style={{display: "flex", flexDirection: "column", alignItems: "center", marginBottom: 28}}>
      <div className="splash-mark" style={{width: 56, height: 56, borderRadius: 16}}>
        <svg viewBox="0 0 24 24" width="28" height="28" fill="none" stroke="white" strokeWidth="2.4" strokeLinecap="round" strokeLinejoin="round"><path d="M8 2v4M16 2v4M12 14l-3 3 1 5 4-2 4 2 1-5-3-3"/><circle cx="12" cy="9" r="3"/></svg>
      </div>
      <h2 style={{fontSize: 22, margin: "16px 0 6px", fontWeight: 700}}>Welcome back</h2>
      <p style={{fontSize: 13, color: "var(--text-2)", margin: 0}}>Continue your training journey.</p>
    </div>

    <div className="stack-md">
      <div className="field"><label>Username</label><input defaultValue="nick.anderson"/></div>
      <div className="field"><label>Password</label><input type="password" defaultValue="••••••••"/></div>
      <div style={{textAlign: "right"}}><a style={{color: "var(--primary)", fontSize: 12, textDecoration: "none"}}>Forgot password?</a></div>
    </div>
    <button className="btn btn-primary" onClick={onLogin} style={{marginTop: 22}}>Sign in</button>
  </div>
);

Object.assign(window, { SplashScreen, WelcomeScreen, RoleScreen, AccountScreen, ProfileSetupScreen, LoginScreen });
