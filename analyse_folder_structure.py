import os
import re
import shutil
import sys
from pathlib import Path

def main():
    project_root_dir = Path.cwd()
    pubspec_file = project_root_dir / 'pubspec.yaml'
    
    if not pubspec_file.exists():
        print('Error: Not a Flutter project. No pubspec.yaml found.')
        sys.exit(1)
    
    print('Flutter Project Structure Analyzer and Tree Shaker')
    print('================================================')
    
    # Analyze project structure
    analyze_project_structure(project_root_dir)
    
    # Analyze imports to find unused code
    unused_files = find_unused_files(project_root_dir)
    
    # Analyze unused packages
    unused_dependencies = find_unused_dependencies(project_root_dir)
    
    # Print recommendations
    print_recommendations(unused_files, unused_dependencies)
    
    # Offer to automatically shake the tree
    perform_tree_shaking(unused_files, unused_dependencies)

def analyze_project_structure(project_dir):
    print('\nAnalyzing project structure...')
    
    directories = {
        'lib': 0,
        'test': 0,
        'assets': 0,
        'web': 0,
        'android': 0,
        'ios': 0,
        'windows': 0,
        'macos': 0,
        'linux': 0,
    }
    
    # Count files in key directories
    for dir_name in directories.keys():
        directory = project_dir / dir_name
        if directory.exists():
            count = sum(1 for _ in directory.glob('**/*') if _.is_file())
            directories[dir_name] = count
            print(f'- {dir_name}: {count} files')
        else:
            print(f'- {dir_name}: directory not found')
    
    # Analyze Dart files structure
    lib_dir = project_dir / 'lib'
    if lib_dir.exists():
        print('\nProject Structure:')
        _print_directory_tree(lib_dir, '', True)

def _print_directory_tree(dir_path, prefix, is_root):
    if is_root:
        print(f'{prefix}lib/')
        prefix = '  '
    
    entities = sorted(dir_path.iterdir(), key=lambda x: x.name)
    
    for i, entity in enumerate(entities):
        is_last = i == len(entities) - 1
        is_dir = entity.is_dir()
        name = entity.name
        
        print(f"{prefix}{'└── ' if is_last else '├── '}{name}{'/' if is_dir else ''}")
        
        if is_dir:
            _print_directory_tree(
                entity,
                f"{prefix}{'    ' if is_last else '│   '}",
                False
            )

def find_unused_files(project_dir):
    print('\nAnalyzing imports to find unused files...')
    
    lib_dir = project_dir / 'lib'
    all_dart_files = []
    all_imports = set()
    unused_files = []
    
    # Get all Dart files
    for file_path in lib_dir.glob('**/*.dart'):
        relative_path = file_path.relative_to(project_dir)
        all_dart_files.append(str(relative_path))
        
        # Get imports from this file
        try:
            content = file_path.read_text(encoding='utf-8')
        except UnicodeDecodeError:
            print(f"Skipping file with encoding issues: {file_path}")
            continue
        
        import_regex = re.compile(r"import\s+['\"]([^'\"]+)['\"](?:\s+as\s+\w+)?(?:\s+hide\s+[\w\s,]+)?(?:\s+show\s+[\w\s,]+)?;")
        matches = import_regex.findall(content)
        
        for import_path in matches:
            if import_path.startswith('package:'):
                continue  # Skip external package imports
            
            if not import_path.startswith('dart:'):
                # Convert relative imports to absolute path
                if import_path.startswith('package:'):
                    parts = import_path.split('/')
                    if len(parts) > 1 and parts[0] == f"package:{_get_project_name(project_dir)}":
                        absolute_path = os.path.join('lib', *parts[1:])
                    else:
                        continue  # Skip external package imports
                else:
                    dir_name = os.path.dirname(file_path)
                    absolute_path = os.path.normpath(os.path.join(
                        os.path.relpath(dir_name, project_dir),
                        import_path
                    ))
                
                # Add .dart extension if not present
                if not absolute_path.endswith('.dart'):
                    absolute_path = f'{absolute_path}.dart'
                
                all_imports.add(absolute_path)
    
    # Find main file and add it to imports (it's always used)
    main_file = next((file for file in all_dart_files if file.endswith('main.dart') or file == 'lib/main.dart'), '')
    
    if main_file:
        all_imports.add(main_file)
    
    # Find unused files
    for file in all_dart_files:
        if file not in all_imports:
            unused_files.append(file)
    
    print(f'Found {len(unused_files)} potentially unused files:')
    for file in unused_files:
        print(f'- {file}')
    
    return unused_files

def find_unused_dependencies(project_dir):
    print('\nAnalyzing unused dependencies...')
    
    pubspec_file = project_dir / 'pubspec.yaml'
    pubspec_content = pubspec_file.read_text(encoding='utf-8')
    
    # Extract dependencies
    dep_regex = re.compile(r'dependencies:\s*\n([\s\S]*?)(?:\n\w+:|$)')
    match = dep_regex.search(pubspec_content)
    
    if not match:
        print('Could not parse dependencies from pubspec.yaml')
        return []
    
    dependencies_section = match.group(1)
    package_regex = re.compile(r'^\s{2}(\w+):.*$', re.MULTILINE)
    packages = [m.group(1) for m in package_regex.finditer(dependencies_section)]
    
    # Find all Dart files
    lib_dir = project_dir / 'lib'
    all_dart_files = list(lib_dir.glob('**/*.dart'))
    
    # Check imports in all files
    used_packages = set()
    
    for file in all_dart_files:
        try:
            content = file.read_text(encoding='utf-8')
        except UnicodeDecodeError:
            print(f"Skipping file with encoding issues: {file}")
            continue
        
        for package in packages:
            if package in ('flutter', 'dart'):
                continue  # Always used
            
            if re.search(f"import\\s+['\"]package:{package}/", content):
                used_packages.add(package)
    
    # Find unused packages
    unused_packages = [pkg for pkg in packages if pkg not in used_packages and pkg not in ('flutter', 'dart')]
    
    print(f'Found {len(unused_packages)} potentially unused dependencies:')
    for package in unused_packages:
        print(f'- {package}')
    
    return unused_packages

def print_recommendations(unused_files, unused_dependencies):
    print('\nTree Shaking Recommendations:')
    
    if not unused_files and not unused_dependencies:
        print('No unused files or dependencies found. Your project is already optimized!')
        return
    
    print('\n1. Unused Files:')
    if not unused_files:
        print('   No unused Dart files detected.')
    else:
        print('   Consider removing these files to reduce app size:')
        for file in unused_files:
            print(f'   - {file}')
    
    print('\n2. Unused Dependencies:')
    if not unused_dependencies:
        print('   No unused dependencies detected.')
    else:
        print('   Consider removing these dependencies from pubspec.yaml:')
        for dep in unused_dependencies:
            print(f'   - {dep}')
    
    print('\nNOTE: Always review the results before deleting any files or dependencies. Some files might be:')
    print('- Used dynamically through reflection or code generation')
    print('- Imported only in test files')
    print('- Required for specific platform builds')
    
    print('\nNOTE: Review carefully before removing:')
    print('- Check if files are used in test directories')
    print('- Verify files are not used via dynamic imports')
    print('- Confirm dependencies are not used in dev/test environments')
    print('- Look for generated code dependencies')
    print('\nUse "flutter pub deps" to see a full dependency tree.')

def perform_tree_shaking(unused_files, unused_dependencies):
    if not unused_files and not unused_dependencies:
        return
    
    print('\nWould you like to automatically remove unused files and update pubspec.yaml? (y/n)')
    response = input().lower()
    
    if response != 'y':
        print('Tree shaking cancelled. No changes made.')
        return
    
    # Create backup folder
    backup_dir = Path.cwd() / 'flutter_tree_shaking_backup'
    if not backup_dir.exists():
        backup_dir.mkdir()
    
    # Handle unused files
    if unused_files:
        print('\nRemoving unused files...')
        
        for file_path in unused_files:
            file = Path.cwd() / file_path
            if file.exists():
                # Create backup
                backup_path = backup_dir / file_path.replace('/', '_')
                shutil.copy2(file, backup_path)
                
                # Delete file
                file.unlink()
                print(f'Removed and backed up: {file_path}')
    
    # Handle unused dependencies
    if unused_dependencies:
        print('\nUpdating pubspec.yaml...')
        
        pubspec_file = Path.cwd() / 'pubspec.yaml'
        pubspec_backup = backup_dir / 'pubspec.yaml.bak'
        
        # Create backup
        shutil.copy2(pubspec_file, pubspec_backup)
        
        # Update pubspec.yaml
        content = pubspec_file.read_text()
        for dep in unused_dependencies:
            dep_regex = re.compile(r'^\s{2}' + re.escape(dep) + r':.*$', re.MULTILINE)
            content = dep_regex.sub(f'  # Removed by tree shaker: {dep}', content)
        
        pubspec_file.write_text(content)
        print('Updated pubspec.yaml')
    
    print('\nTree shaking complete!')
    print(f'Backups created in: {backup_dir}')
    print('\nRun "flutter pub get" to update dependencies.')
    print('Run "flutter clean && flutter build" to rebuild your app with new optimizations.')

def _get_project_name(project_dir):
    pubspec_file = project_dir / 'pubspec.yaml'
    content = pubspec_file.read_text()
    
    name_regex = re.compile(r'^name:\s+(.*)$', re.MULTILINE)
    match = name_regex.search(content)
    
    return match.group(1).strip() if match else ''

if __name__ == "__main__":
    main()