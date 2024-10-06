let scene, camera, renderer, controls;
let planets = [], exoplanets = [];
let starfield;
let raycaster, mouse;
let planetLabels = [], exoplanetLabels = [];
let textureLoader = new THREE.TextureLoader();

function init() {
    scene = new THREE.Scene();
    camera = new THREE.PerspectiveCamera(75, window.innerWidth / window.innerHeight, 0.1, 1000);
    renderer = new THREE.WebGLRenderer({ antialias: true });
    renderer.setSize(window.innerWidth, window.innerHeight);
    
    const planetarium = document.getElementById('planetarium');
    const exoplanetarium = document.getElementById('exoplanetarium');
    
    if (planetarium) {
        planetarium.appendChild(renderer.domElement);
    } else if (exoplanetarium) {
        exoplanetarium.appendChild(renderer.domElement);
    }

    camera.position.z = 50;

    controls = new THREE.OrbitControls(camera, renderer.domElement);
    controls.enableDamping = true;
    controls.dampingFactor = 0.05;

    createStarfield();

    raycaster = new THREE.Raycaster();
    mouse = new THREE.Vector2();

    window.addEventListener('resize', onWindowResize, false);
    renderer.domElement.addEventListener('click', onMouseClick, false);

    // Add a light source
    const light = new THREE.PointLight(0xffffff, 1, 100);
    light.position.set(0, 0, 10);
    scene.add(light);

    animate();
}

function createStarfield() {
    // ... (previous createStarfield code)
}

function createCelestialBody(data, isExoplanet) {
    const size = isExoplanet ? 0.5 : data.radius * 0.5;
    const geometry = new THREE.SphereGeometry(size, 32, 32);
    const material = new THREE.MeshPhongMaterial();
    
    if (isExoplanet) {
        material.color.setHSL(Math.random(), 0.5, 0.5);
    } else {
        textureLoader.load(data.image_url, function(texture) {
            material.map = texture;
            material.needsUpdate = true;
        });
    }
    
    const body = new THREE.Mesh(geometry, material);
    const distance = isExoplanet ? Math.random() * 80 + 20 : data.distance * 2;
    const angle = Math.random() * Math.PI * 2;
    body.position.set(
        distance * Math.cos(angle),
        distance * Math.sin(angle),
        (Math.random() - 0.5) * 20
    );
    body.userData = data;
    scene.add(body);

    if (isExoplanet) {
        exoplanets.push(body);
    } else {
        planets.push(body);
    }

    // Create label
    const label = createLabel(data.name, body.position);
    if (isExoplanet) {
        exoplanetLabels.push(label);
    } else {
        planetLabels.push(label);
    }
    scene.add(label);
}

// ... (rest of the previous JavaScript code)

Shiny.addCustomMessageHandler("initializeExoplanets", function(data) {
    // Clear existing exoplanets
    exoplanets.forEach(exoplanet => scene.remove(exoplanet));
    exoplanetLabels.forEach(label => scene.remove(label));
    exoplanets = [];
    exoplanetLabels = [];

    data.forEach(exoplanet => createCelestialBody(exoplanet, true));
});

init();