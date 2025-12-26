function runAlgo(algo) {
    const pages = document.getElementById("pages").value;
    const frames = document.getElementById("frames").value;

    fetch('/run', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
            pages: pages,
            frames: frames,
            algorithm: algo
        })
    })
    .then(res => res.json())
    .then(data => {
        document.getElementById("output").innerText = data;
    });
}
