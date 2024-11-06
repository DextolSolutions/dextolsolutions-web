import { useRef } from "react";
import "./Navbar.css";
import logo from "../assets/logo.png"; // Updated path for logo

function Navbar() {
	const navRef = useRef();
	const scrollToSection = () => {
		const element = document.getElementById('projects'); // Targeting the projects section
		if (element) {
		  element.scrollIntoView({ behavior: 'smooth', block: 'start' });
		}
	  };

	return (
		<header>
			<img src={logo} alt="Logo" className="logo" />
			<div className="logo-text">
				<span className="logo-title">DextolSolutions</span>
				<span className="logo-subtitle">Coding is our Hobby.</span>
			</div>
			<nav ref={navRef} className="nav-links">
				<a href="/#" onClick={scrollToSection}>ZenSL Optimizer</a> {/* Added id for scrolling */}
				<a href="/projects">Projects</a>                     {/* Updated path */}
				<a href="/about">About</a>                           {/* Updated path */}
				<a href="https://discord.com/invite/jTpB2VZZ4q" className="join-discord">Join Discord</a> {/* Discord invite link */}
			</nav>
		</header>
	);
}

export default Navbar;
