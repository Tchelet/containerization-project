from flask import Flask, render_template, request, redirect, url_for
import requests
from prometheus_flask_exporter import PrometheusMetrics

app = Flask(__name__, template_folder='templates')
metrics = PrometheusMetrics(app)

@app.route('/')
def index():
    response = requests.get('http://backend-service:5000/tasks')
    tasks = response.json()
    return render_template('index.html', tasks=tasks)

@app.route('/add', methods=['GET', 'POST'])
def add_task():
    if request.method == 'POST':
        new_task = {
            "title": request.form['title'],
            "description": request.form['description']
        }
        requests.post('http://backend-service:5000/tasks', json=new_task)
        return redirect(url_for('index'))
    return render_template('add_task.html')

@app.route('/edit/<int:task_id>', methods=['GET', 'POST'])
def edit_task(task_id):
    if request.method == 'POST':
        updated_task = {
            "title": request.form['title'],
            "description": request.form['description']
        }
        requests.put(f'http://backend-service:5000/tasks/{task_id}', json=updated_task)
        return redirect(url_for('index'))
    response = requests.get(f'http://backend-service:5000/tasks/{task_id}')
    task = response.json()
    return render_template('edit_task.html', task=task)

@app.route('/delete/<int:task_id>', methods=['POST'])
def delete_task(task_id):
    requests.delete(f'http://backend-service:5000/tasks/{task_id}')
    return redirect(url_for('index'))

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8000)