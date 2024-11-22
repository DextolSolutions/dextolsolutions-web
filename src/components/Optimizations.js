import './Optimizations.css';

function Projects() {
  return (
    <div>
      <section className='projects-section'>
        <h1 className="projects-title">OPTIMIZATIONS</h1>
        <p className="projects-subtitle">Our Optimizations Scripts To Optimize Your Computer</p>
        <div className="boxes-container">
          {/* Box 1 */}
          <div className="box">
            <i className="fas fa-tachometer-alt box-icon"></i>
            <h3>Performance Boost</h3>
            <p>Enhance your computer's speed with this script.</p>
            <a href="/download/performance-boost" className="download-button-optimizations">Download</a>
          </div>
          {/* Box 2 */}
          <div className="box">
            <i className="fas fa-code box-icon"></i>
            <h3>Code Cleaner</h3>
            <p>Eliminate unnecessary files and optimize system code efficiency.</p>
            <a href="/download/code-cleaner" className="download-button-optimizations">Download</a>
          </div>
          {/* Box 3 */}
          <div className="box">
            <i className="fas fa-chart-line box-icon"></i>
            <h3>Resource Monitor</h3>
            <p>Track and reduce resource usage to maintain peak performance.</p>
            <a href="/download/resource-monitor" className="download-button-optimizations">Download</a>
          </div>
          {/* Box 4 */}
          <div className="box">
            <i className="fas fa-database box-icon"></i>
            <h3>Data Optimizer</h3>
            <p>Streamline data storage and minimize redundant files.</p>
            <a href="/download/data-optimizer" className="download-button-optimizations">Download</a>
          </div>
          {/* Box 5 */}
          <div className="box">
            <i className="fas fa-cogs box-icon"></i>
            <h3>System Tuner</h3>
            <p>tune system settings for a smoother user experience.</p>
            <a href="/download/system-tuner" className="download-button-optimizations">Download</a>
          </div>
          {/* Box 6 */}
          <div className="box">
            <i className="fas fa-shield-alt box-icon"></i>
            <h3>Security Enhancer</h3>
            <p>Boost your system's security to protect against vulnerabilities.</p>
            <a href="/download/security-enhancer" className="download-button-optimizations">Download</a>
          </div>
        </div>
      </section>
    </div>
  );
}

export default Projects;
