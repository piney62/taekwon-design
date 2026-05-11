// Shared UI building blocks
const { useState, useEffect, useRef } = React;

const StatusBar = () => (
  <div className="status-bar">
    <span>9:41</span>
    <span className="status-icons">
      <svg width="16" height="11" viewBox="0 0 16 11"><path d="M0 9h2v2H0zm4-2h2v4H4zm4-3h2v7H8zm4-3h2v10h-2z" fill="currentColor"/></svg>
      <svg width="14" height="11" viewBox="0 0 14 11"><path d="M7 2.5c1.8 0 3.5.7 4.8 1.9l1.4-1.4C11.4 1.2 9.2.3 7 .3S2.6 1.2.8 3l1.4 1.4C3.5 3.2 5.2 2.5 7 2.5z M7 6.5c.9 0 1.7.3 2.4 1l1.4-1.4c-1-1-2.3-1.5-3.8-1.5s-2.8.5-3.8 1.5L4.6 7.5c.7-.7 1.5-1 2.4-1zm0 4c.6 0 1-.4 1-1s-.4-1-1-1-1 .4-1 1 .4 1 1 1z" fill="currentColor"/></svg>
      <svg width="24" height="11" viewBox="0 0 24 11"><rect x="0.5" y="0.5" width="20" height="10" rx="2.5" stroke="currentColor" fill="none"/><rect x="2" y="2" width="16" height="7" rx="1" fill="currentColor"/><rect x="21" y="3.5" width="1.5" height="4" fill="currentColor"/></svg>
    </span>
  </div>
);

const TabBar = ({ tab, setTab, role }) => {
  const items = role === "instructor"
    ? [
        { k: "home", label: "Home", icon: "home", c: "primary" },
        { k: "analyze", label: "Analyze", icon: "activity", c: "secondary" },
        { k: "dojang", label: "Dojang", icon: "users", c: "accent" },
        { k: "patterns", label: "Patterns", icon: "book", c: "primary" },
        { k: "me", label: "Me", icon: "user", c: "secondary" },
      ]
    : [
        { k: "home", label: "Home", icon: "home", c: "primary" },
        { k: "analyze", label: "Analyze", icon: "activity", c: "secondary" },
        { k: "journal", label: "Journal", icon: "trending", c: "accent" },
        { k: "patterns", label: "Patterns", icon: "book", c: "primary" },
        { k: "me", label: "Me", icon: "user", c: "secondary" },
      ];
  return (
    <nav className="tabbar">
      {items.map(it => {
        const active = tab === it.k;
        const t2 = it.c === "secondary" || it.c === "accent";
        return (
          <button key={it.k} className={`tab-btn ${active ? "active active-bg" : ""} ${t2 ? "t-2" : ""}`} onClick={() => setTab(it.k)}>
            <Icon name={it.icon} size={20}/>
            <span>{it.label}</span>
          </button>
        );
      })}
    </nav>
  );
};

const TopBar = ({ title, onBack, action }) => (
  <div className="topbar">
    {onBack && <button className="back" onClick={onBack}><Icon name="chevronLeft" size={18}/></button>}
    <h2 style={{flex: 1}}>{title}</h2>
    {action}
  </div>
);

const StatCard = ({ icon, value, label, color = "primary" }) => (
  <div className="stat">
    <div className={`icon-chip chip-${color}`}><Icon name={icon} size={18}/></div>
    <div className="val">{value}</div>
    <div className="lbl">{label}</div>
  </div>
);

const ListRow = ({ icon, iconColor = "primary", title, sub, right, onClick, locked }) => (
  <div className="row" onClick={onClick} style={locked ? {opacity: 0.5} : null}>
    <div className="avatar" style={{background: locked ? "var(--muted)" : `rgba(${iconColor === 'primary' ? '239,68,68' : iconColor === 'secondary' ? '59,130,246' : '139,92,246'}, 0.12)`}}>
      {locked ? <Icon name="lock" size={18} stroke="var(--text-3)"/> : <Icon name={icon} size={18} stroke={iconColor === 'primary' ? 'var(--primary)' : iconColor === 'secondary' ? 'var(--secondary)' : 'var(--accent)'}/>}
    </div>
    <div className="body">
      <div className="t">{title}</div>
      <div className="s">{sub}</div>
    </div>
    {right || <div className="chev"><Icon name="chevron" size={16}/></div>}
  </div>
);

const ProgressRing = ({ value, size = 120, stroke = 10 }) => {
  const r = (size - stroke) / 2;
  const c = 2 * Math.PI * r;
  const offset = c - (value / 100) * c;
  return (
    <svg width={size} height={size} viewBox={`0 0 ${size} ${size}`}>
      <defs>
        <linearGradient id="ringGrad" x1="0%" y1="0%" x2="100%" y2="100%">
          <stop offset="0%" stopColor="#ef4444"/>
          <stop offset="100%" stopColor="#3b82f6"/>
        </linearGradient>
      </defs>
      <circle cx={size/2} cy={size/2} r={r} fill="none" stroke="rgba(255,255,255,0.08)" strokeWidth={stroke}/>
      <circle cx={size/2} cy={size/2} r={r} fill="none" stroke="url(#ringGrad)" strokeWidth={stroke} strokeLinecap="round" strokeDasharray={c} strokeDashoffset={offset} transform={`rotate(-90 ${size/2} ${size/2})`}/>
      <text x="50%" y="50%" textAnchor="middle" dy="0.35em" fill="white" fontSize={size/4} fontWeight="700">{value}%</text>
    </svg>
  );
};

const FeatureCard = ({ label, title, body, progress, primaryLabel, secondaryLabel, onPrimary, onSecondary, icon = "zap" }) => (
  <div className="feature">
    <div className="label"><Icon name={icon} size={16}/><span>{label}</span></div>
    <h3>{title}</h3>
    {body && <p>{body}</p>}
    {progress != null && (
      <div className="progress-track" style={{marginBottom: 18}}>
        <div className="progress-fill" style={{width: progress + "%"}}/>
      </div>
    )}
    <div className="actions">
      {primaryLabel && <button className="btn-white" onClick={onPrimary}>{primaryLabel}</button>}
      {secondaryLabel && <button className="btn-ghost" onClick={onSecondary}>{secondaryLabel}</button>}
    </div>
  </div>
);

const Modal = ({ children, onClose, title }) => (
  <div className="modal-overlay" onClick={onClose}>
    <div className="modal-sheet" onClick={e => e.stopPropagation()}>
      <div className="modal-grab"/>
      {title && <h2 style={{margin: "0 0 18px", fontSize: 20, fontWeight: 700}}>{title}</h2>}
      {children}
    </div>
  </div>
);

const Placeholder = ({ label, height = 160, style }) => (
  <div className="ph" style={{height, ...style}}>
    <div>
      <div style={{opacity: 0.6, marginBottom: 4}}>{"// placeholder"}</div>
      <div>{label}</div>
    </div>
  </div>
);

Object.assign(window, { StatusBar, TabBar, TopBar, StatCard, ListRow, ProgressRing, FeatureCard, Modal, Placeholder });
