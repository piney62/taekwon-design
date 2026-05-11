// Main app — navigation, tweaks, screen routing
const { useState: useS, useEffect: useE } = React;

const DEFAULTS = /*EDITMODE-BEGIN*/{
  "role": "student",
  "startAt": "home",
  "showOnboardingFlow": false,
  "accentMode": "fire-ice",
  "theme": "dark"
}/*EDITMODE-END*/;

function App() {
  const [t, setTweak] = useTweaks(DEFAULTS);
  useE(() => { document.documentElement.dataset.theme = t.theme === "light" ? "light" : "dark"; }, [t.theme]);
  const [tab, setTab] = useS(t.startAt && ["home","analyze","journal","patterns","me","dojang"].includes(t.startAt) ? t.startAt : "home");
  const [screen, setScreen] = useS(t.showOnboardingFlow ? "splash" : null);
  const [modal, setModal] = useS(null);
  const [history, setHistory] = useS([]);

  // Sync role
  useE(() => {
    // If role changes and tab is the role-specific one, reset
    if (t.role === "student" && tab === "dojang") setTab("home");
    if (t.role === "instructor" && tab === "journal") setTab("home");
  }, [t.role]);

  useE(() => {
    if (t.showOnboardingFlow && !screen) setScreen("splash");
    if (!t.showOnboardingFlow && screen === "splash") setScreen(null);
  }, [t.showOnboardingFlow]);

  const navigate = (s) => {
    if (s === "back") {
      setHistory(h => { const nh = [...h]; nh.pop(); setScreen(nh.length ? nh[nh.length - 1] : null); return nh; });
      return;
    }
    setHistory(h => [...h, s]);
    setScreen(s);
  };
  const back = () => {
    setHistory(h => {
      const nh = [...h]; nh.pop();
      setScreen(nh.length ? nh[nh.length - 1] : null);
      return nh;
    });
  };
  const goHome = () => { setScreen(null); setHistory([]); };

  // Onboarding flow ------------
  if (screen === "splash") return <Wrap><SplashScreen onContinue={() => setScreen("welcome")}/></Wrap>;
  if (screen === "welcome") return <Wrap><WelcomeScreen goRole={() => setScreen("role")} goLogin={() => setScreen("login")}/></Wrap>;
  if (screen === "role") return <Wrap><RoleScreen role={t.role} setRole={(r) => setTweak("role", r)} onBack={() => setScreen("welcome")} onNext={() => setScreen("account")}/></Wrap>;
  if (screen === "account") return <Wrap><AccountScreen onBack={() => setScreen("role")} onNext={() => setScreen("profileSetup")}/></Wrap>;
  if (screen === "profileSetup") return <Wrap><ProfileSetupScreen role={t.role} onBack={() => setScreen("account")} onFinish={() => { setTweak("showOnboardingFlow", false); setScreen(null); }}/></Wrap>;
  if (screen === "login") return <Wrap><LoginScreen onBack={() => setScreen("welcome")} onLogin={() => { setTweak("showOnboardingFlow", false); setScreen(null); }}/></Wrap>;

  // Drill-down screens ------------
  const drilldowns = {
    analyzeResult: <AnalyzeResult navigate={navigate} onBack={back}/>,
    analyzeHistory: <AnalyzeHistory navigate={navigate} onBack={back}/>,
    weakPoints: <WeakPointsDetail navigate={() => { setTab("analyze"); goHome(); }} onBack={back}/>,
    beltProgress: <BeltProgressDetail onBack={back}/>,
    allRecords: <AllRecords onBack={back} openModal={() => setModal("addTraining")}/>,
    patternDetail: <PatternDetail onBack={back}/>,
    terminology: <TerminologyScreen onBack={back}/>,
    tenets: <TenetsScreen onBack={back}/>,
    history: <HistoryScreen onBack={back}/>,
    coach: <CoachScreen onBack={back}/>,
    studentDetail: <StudentDetail onBack={back}/>,
    editProfile: null,
    changePassword: null,
  };

  let body;
  if (screen && drilldowns[screen]) {
    body = drilldowns[screen];
  } else {
    if (t.role === "instructor") {
      if (tab === "home") body = <InstructorHome navigate={(s) => s === "me" ? setTab("me") : s === "dojang" ? setTab("dojang") : s === "inviteModal" ? setModal("invite") : navigate(s)}/>;
      else if (tab === "analyze") body = <AnalyzeEntry navigate={navigate}/>;
      else if (tab === "dojang") body = <DojangMain navigate={(s) => s === "inviteModal" ? setModal("invite") : navigate(s)} openModal={() => setModal("invite")}/>;
      else if (tab === "patterns") body = <PatternsMain navigate={navigate}/>;
      else if (tab === "me") body = <MeScreen role={t.role} navigate={(s) => s === "editProfile" ? setModal("editProfile") : s === "changePassword" ? setModal("changePassword") : navigate(s)} openLogoutModal={() => setModal("logout")}/>;
    } else {
      if (tab === "home") body = <StudentHome navigate={(s) => s === "me" ? setTab("me") : s === "analyze" ? setTab("analyze") : navigate(s)}/>;
      else if (tab === "analyze") body = <AnalyzeEntry navigate={navigate} prefill/>;
      else if (tab === "journal") body = <JournalMain navigate={navigate} openModal={() => setModal("addTraining")}/>;
      else if (tab === "patterns") body = <PatternsMain navigate={navigate}/>;
      else if (tab === "me") body = <MeScreen role={t.role} navigate={(s) => s === "editProfile" ? setModal("editProfile") : s === "changePassword" ? setModal("changePassword") : navigate(s)} openLogoutModal={() => setModal("logout")}/>;
    }
  }

  return (
    <Wrap>
      <div className="screen-body">{body}</div>
      {!screen && <TabBar tab={tab} setTab={(k) => { setTab(k); }} role={t.role}/>}
      {modal === "addTraining" && <AddTrainingModal onClose={() => setModal(null)}/>}
      {modal === "invite" && <InviteModal onClose={() => setModal(null)}/>}
      {modal === "editProfile" && <EditProfileModal onClose={() => setModal(null)}/>}
      {modal === "changePassword" && <ChangePasswordModal onClose={() => setModal(null)}/>}
      {modal === "logout" && (
        <Modal onClose={() => setModal(null)} title="Log out?">
          <p style={{fontSize: 13, color: "var(--text-2)", margin: "0 0 18px"}}>You'll need to sign in again to continue training.</p>
          <div style={{display: "flex", gap: 10}}>
            <button className="btn btn-secondary" onClick={() => setModal(null)}>Cancel</button>
            <button className="btn btn-destructive" onClick={() => { setModal(null); setTweak("showOnboardingFlow", true); setScreen("welcome"); }}>Log out</button>
          </div>
        </Modal>
      )}

      <TweaksPanel title="Tweaks" defaultPosition={{x: 24, y: 24}}>
        <TweakSection title="Appearance">
          <TweakRadio label="Theme" value={t.theme} options={[{value: "dark", label: "Dark"}, {value: "light", label: "Light"}]} onChange={v => setTweak("theme", v)}/>
        </TweakSection>
        <TweakSection title="Role">
          <TweakRadio label="View as" value={t.role} options={[{value: "student", label: "Student"}, {value: "instructor", label: "Instructor"}]} onChange={v => setTweak("role", v)}/>
        </TweakSection>
        <TweakSection title="Jump to flow">
          <TweakToggle label="Show onboarding" value={!!t.showOnboardingFlow} onChange={v => { setTweak("showOnboardingFlow", v); if (v) setScreen("splash"); else { setScreen(null); setHistory([]); } }}/>
          <TweakSelect label="Tab" value={tab} options={t.role === "instructor"
            ? [{value:"home", label:"Home"}, {value:"analyze", label:"Analyze"}, {value:"dojang", label:"Dojang"}, {value:"patterns", label:"Patterns"}, {value:"me", label:"Me"}]
            : [{value:"home", label:"Home"}, {value:"analyze", label:"Analyze"}, {value:"journal", label:"Journal"}, {value:"patterns", label:"Patterns"}, {value:"me", label:"Me"}]
          } onChange={v => { setTab(v); setScreen(null); setHistory([]); }}/>
          <TweakSelect label="Drill-down" value={screen || ""} options={[
            {value: "", label: "— None —"},
            {value: "analyzeResult", label: "Analyze Result"},
            {value: "analyzeHistory", label: "Analyze History"},
            {value: "patternDetail", label: "Pattern Detail"},
            {value: "weakPoints", label: "Weak Points"},
            {value: "beltProgress", label: "Belt Progress"},
            {value: "allRecords", label: "All Records"},
            {value: "terminology", label: "Terminology"},
            {value: "tenets", label: "5 Tenets"},
            {value: "history", label: "ITF History"},
            {value: "coach", label: "Coach"},
            {value: "studentDetail", label: "Student Detail"},
          ]} onChange={v => { if (v) { setScreen(v); setHistory([v]); } else { setScreen(null); setHistory([]); } }}/>
          <TweakSelect label="Modal" value={modal || ""} options={[
            {value: "", label: "— None —"},
            {value: "addTraining", label: "Add Training"},
            {value: "invite", label: "Invite QR"},
            {value: "editProfile", label: "Edit Profile"},
            {value: "changePassword", label: "Change Password"},
            {value: "logout", label: "Logout Confirm"},
          ]} onChange={v => setModal(v || null)}/>
        </TweakSection>
      </TweaksPanel>
    </Wrap>
  );
}

function Wrap({ children }) {
  return <>{children}<div className="home-indicator"/></>;
}

ReactDOM.createRoot(document.getElementById("app-root")).render(<App/>);
