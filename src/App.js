function App() {
  return (
    <div style={{
      textAlign: "center",
      marginTop: "50px",
      fontFamily: "Arial, sans-serif"
    }}>
      <h1>🚀 DevOps CI/CD Project</h1>
      <p>Deployed using Docker, AWS EC2 & GitHub Actions</p>
      <div style={{
        marginTop: "30px",
        display: "flex",
        justifyContent: "center",
        gap: "20px",
        flexWrap: "wrap"
      }}>
        {["React", "Docker", "GitHub Actions", "AWS EC2", "Terraform"].map(tech => (
          <span key={tech} style={{
            background: "#0078d4",
            color: "white",
            padding: "8px 16px",
            borderRadius: "20px",
            fontSize: "14px"
          }}>
            {tech}
          </span>
        ))}
      </div>
    </div>
  );
}

export default App;
