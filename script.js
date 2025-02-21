// Animate title with GSAP
gsap.to("#title", { duration: 2, opacity: 1, y: -10 });

// Canvas animation (simple moving dots)
const canvas = document.getElementById("animationCanvas");
const ctx = canvas.getContext("2d");

canvas.width = window.innerWidth;
canvas.height = window.innerHeight / 3;

let particles = [];

function Particle(x, y, size, speedX, speedY) {
    this.x = x;
    this.y = y;
    this.size = size;
    this.speedX = speedX;
    this.speedY = speedY;

    this.draw = function() {
        ctx.fillStyle = "white";
        ctx.beginPath();
        ctx.arc(this.x, this.y, this.size, 0, Math.PI * 2);
        ctx.fill();
    };

    this.update = function() {
        this.x += this.speedX;
        this.y += this.speedY;

        if (this.x > canvas.width || this.x < 0) this.speedX *= -1;
        if (this.y > canvas.height || this.y < 0) this.speedY *= -1;

        this.draw();
    };
}

// Create particles
for (let i = 0; i < 50; i++) {
    let size = Math.random() * 5 + 2;
    let x = Math.random() * canvas.width;
    let y = Math.random() * canvas.height;
    let speedX = (Math.random() - 0.5) * 2;
    let speedY = (Math.random() - 0.5) * 2;
    particles.push(new Particle(x, y, size, speedX, speedY));
}

// Animate particles
function animate() {
    ctx.clearRect(0, 0, canvas.width, canvas.height);
    particles.forEach(p => p.update());
    requestAnimationFrame(animate);
}

animate();
