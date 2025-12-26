# memory


    for page in pages:
        if page not in frames:
            frames[index] = page
            index = (index + 1) % f
            faults += 1
            result += f"{page}\t{display_frames(frames)}\tFault\n"
        else:
            result += f"{page}\t{display_frames(frames)}\tHit\n"

    result += f"\nTotal Page Faults (FIFO) = {faults}"
    return result

def lru(pages, f):
    frames = [-1] * f
    time = [0] * f
    counter = 0
    faults = 0
    result = ""

    for page in pages:
        counter += 1
        if page in frames:
            i = frames.index(page)
            time[i] = counter
            result += f"{page}\t{display_frames(frames)}\tHit\n"
        else:
            pos = time.index(min(time))
            frames[pos] = page
            time[pos] = counter
            faults += 1
            result += f"{page}\t{display_frames(frames)}\tFault\n"

    result += f"\nTotal Page Faults (LRU) = {faults}"
    return result

def optimal(pages, f):
    frames = [-1] * f
    faults = 0
    result = ""

    for i, page in enumerate(pages):
        if page in frames:
            result += f"{page}\t{display_frames(frames)}\tHit\n"
            continue

        pos = -1
        farthest = -1
        for j in range(f):
            if frames[j] == -1:
                pos = j
                break
            try:
                idx = pages[i+1:].index(frames[j])
            except ValueError:
                pos = j
                break
            if idx > farthest:
                farthest = idx
                pos = j

        frames[pos] = page
        faults += 1
        result += f"{page}\t{display_frames(frames)}\tFault\n"

    result += f"\nTotal Page Faults (Optimal) = {faults}"
    return result

@app.route('/')
def index():
    return render_template('index.html')

@app.route('/run', methods=['POST'])
def run_algo():
    data = request.json
    pages = list(map(int, data['pages'].split()))
    frames = int(data['frames'])
    algo = data['algorithm']

    if algo == 'FIFO':
        output = fifo(pages, frames)
    elif algo == 'LRU':
        output = lru(pages, frames)
    else:
        output = optimal(pages, frames)

    return jsonify(output)

if __name__ == '__main__':
    app.run(debug=True)
    <!DOCTYPE html>
<html>
<head>
    <title>Virtual Memory Management</title>
    <link rel="stylesheet" href="/static/style.css">
</head>
<body>

<h1>Virtual Memory Management</h1>

<label>Page Reference String:</label>
<input type="text" id="pages" placeholder="1 2 3 4 1 2">

<label>Number of Frames:</label>
<input type="number" id="frames">

<div class="buttons">
    <button onclick="runAlgo('FIFO')">FIFO</button>
    <button onclick="runAlgo('LRU')">LRU</button>
    <button onclick="runAlgo('Optimal')">Optimal</button>
</div>

<pre id="output"></pre>

<script src="/static/script.js"></script>
</body>
</html>
body {
    font-family: Arial;
    background: #f4f4f4;
    padding: 20px;
}

h1 {
    text-align: center;
}

input {
    width: 100%;
    padding: 8px;
    margin: 5px 0;
}

.buttons {
    text-align: center;
    margin: 10px;
}

button {
    padding: 10px 20px;
    margin: 5px;
    cursor: pointer;
}

pre {
    background: white;
    padding: 15px;
    height: 300px;
    overflow: auto;
}
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
