from flask import Flask, render_template, request, jsonify

app = Flask(__name__)

def display_frames(frames):
    return " ".join(str(f) if f != -1 else "-" for f in frames)

def fifo(pages, f):
    frames = [-1] * f
    index = 0
    faults = 0
    result = ""

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
