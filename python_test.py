import json

def get_dependencies(model_name, manifest_path):
    with open(manifest_path, 'r') as f:
        manifest = json.load(f)

    nodes = manifest['nodes']
    dependencies = []

    def get_dependencies_helper(node_name):
        if node_name not in nodes:
            return
        node = nodes[node_name]
        dependencies.extend(node['depends_on']['nodes'])
        for dependency in node['depends_on']['nodes']:
            get_dependencies_helper(dependency)

    get_dependencies_helper(model_name)
    return dependencies

# Specify the model name and manifest path
model_name = 'model_name'
manifest_path = 'path/to/manifest.json'

# Get the dependencies of the model
dependencies = get_dependencies(model_name, manifest_path)

# Print the dependencies
print(dependencies)
