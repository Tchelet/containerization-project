from flask import Flask, jsonify, request
from flask_sqlalchemy import SQLAlchemy
from prometheus_flask_exporter import PrometheusMetrics

app = Flask(__name__)
app.config['SQLALCHEMY_DATABASE_URI'] = 'postgresql://user:password@db:5432/tasks_db'
db = SQLAlchemy(app)
metrics = PrometheusMetrics(app)

class Task(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    title = db.Column(db.String(80), nullable=False)
    description = db.Column(db.String(200), nullable=False)

with app.app_context():
    db.create_all()

@app.route('/tasks', methods=['GET'])
def get_tasks():
    tasks = Task.query.all()
    return jsonify([{"id": task.id, "title": task.title, "description": task.description} for task in tasks])

@app.route('/tasks', methods=['POST'])
def add_task():
    new_task = Task(
        title=request.json['title'],
        description=request.json['description']
    )
    db.session.add(new_task)
    db.session.commit()
    return jsonify({"id": new_task.id, "title": new_task.title, "description": new_task.description}), 201

@app.route('/tasks/<int:task_id>', methods=['GET'])
def get_task(task_id):
    task = Task.query.get_or_404(task_id)
    return jsonify({"id": task.id, "title": task.title, "description": task.description})

@app.route('/tasks/<int:task_id>', methods=['PATCH'])
def update_task(task_id):
    task = Task.query.get_or_404(task_id)
    if 'title' in request.json:
        task.title = request.json['title']
    if 'description' in request.json:
        task.description = request.json['description']
    db.session.commit()
    return jsonify({"id": task.id, "title": task.title, "description": task.description})

@app.route('/tasks/<int:task_id>', methods=['DELETE'])
def delete_task(task_id):
    task = Task.query.get_or_404(task_id)
    db.session.delete(task)
    db.session.commit()
    return '', 204

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)