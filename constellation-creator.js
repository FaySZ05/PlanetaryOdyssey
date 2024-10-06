let scene, camera, renderer, controls;
let stars = [];
let constellationLines = [];
let raycaster, mouse;
let starField;

function init() {
    scene = new THREE.Scene();
    camera = new THREE.PerspectiveCamera(75, window.innerWidth / window.innerHeight, 0.1, 1000);
    renderer = new THREE.WebGLRenderer({ antialias: true });
    renderer.setSize(window.innerWidth, window.innerHeight);
    
    document.getElementById('constellation-creator').appendChild(renderer.domElement);

    camera.position.z = 5;

    controls = new THREE.OrbitControls(camera, renderer.domElement);
    controls.enableDamping = true;
    controls.dampingFactor = 0.05;

    createStarField();

    raycaster = new THREE.Raycaster();
    mouse = new THREE.Vector2();

    window.addEventListener('resize', onWindowResize, false);
    renderer.domElement.addEventListener('click', onStarClick, false);

    animate();
}

function createStarField() {
    // Create a random star field
    const geometry = new THREE.BufferGeometry();
    const vertices = [];
    
    for (let i = 0; i < 10000; i++) {
        const x = THREE.MathUtils.randFloatSpread(2000);
        const y = THREE.MathUtils.randFloatSpread(2000);
        const z = THREE.MathUtils.randFloatSpread(2000);
        vertices.push(x, y, z);
    }
    
    geometry.setAttribute('position', new THREE.Float32BufferAttribute(vertices, 3));
    
    const material = new THREE.PointsMaterial({ color: 0xffffff, size: 0.1 });
    starField = new THREE.Points(geometry, material);
    scene.add(starField);
}

function onStarClick(event) {
    // Handle star selection and constellation creation
    mouse.x = (event.clientX / window.innerWidth) * 2 - 1;
    mouse.y = - (event.clientY / window.innerHeight) * 2 + 1;

    raycaster.setFromCamera(mouse, camera);

    const intersects = raycaster.intersectObject(starField);

    if (intersects.length > 0) {
        const selectedStar = intersects[0].point;
        // Add star to constellation or trigger Shiny event
        Shiny.setInputValue("selectedStar", `Star at (${selectedStar.