import os

def replace_in_file(file_path, old, new):
    """
    Reads a file, replaces all occurrences of 'old' with 'new' in its contents,
    and writes back if any changes were made.
    """
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()
    except Exception as e:
        print(f"Skipping {file_path}: cannot read file. ({e})")
        return

    new_content = content.replace(old, new)
    if new_content != content:
        try:
            with open(file_path, 'w', encoding='utf-8') as f:
                f.write(new_content)
            print(f"Updated content in: {file_path}")
        except Exception as e:
            print(f"Error writing to {file_path}: {e}")

def rename_file_or_dir(path, old, new):
    """            
    If the given file or directory name contains 'old', rename it by replacing 'old' with 'new'.
    Returns the new path if renamed, otherwise returns the original path.
    """
    directory, name = os.path.split(path)
    if old in name:
        new_name = name.replace(old, new)
        new_path = os.path.join(directory, new_name)
        try:
            os.rename(path, new_path)
            print(f"Renamed: {path} -> {new_path}")
            return new_path
        except Exception as e:
            print(f"Error renaming {path}: {e}")
    return path

# def process_directory(root_dir, old, new):
def process_directory(root_dir, old, new, skip_files=None, skip_dirs=None):
    """
    Walks through the directory tree and for each file:
        - Renames files (and directories) that have 'old' in their name.
        - Replaces 'old' with 'new' in their file contents.
    
    We use bottom-up traversal (topdown=False) to ensure that files inside a renamed directory are processed correctly.

    Recursively processes the directory tree, renaming files and directories that contain 'old'
    and replacing 'old' with 'new' in file contents. Files and directories whose names are in the
    skip list are not processed.
    """

    if skip_files is None:
        skip_files = []
    if skip_dirs is None:
        skip_dirs = []

    for dirpath, dirnames, filenames in os.walk(root_dir, topdown=False):
        # Process files
        for filename in filenames:
            if filename in skip_files:
                print(f"Skipping file: {filename}")
                continue
            file_path = os.path.join(dirpath, filename)
            # Rename file if needed
            new_file_path = rename_file_or_dir(file_path, old, new)
            # Replace content in the (possibly renamed) file
            replace_in_file(new_file_path, old, new)
        # Process directories (rename them if necessary)
        for i, dirname in enumerate(dirnames):
            if dirname in skip_dirs:
                print(f"Skipping directory: {dirname}")
                continue
            old_dir_path = os.path.join(dirpath, dirname)
            new_dir_path = rename_file_or_dir(old_dir_path, old, new)
            dirnames[i] = os.path.basename(new_dir_path)
            # Update the directory name in the list for os.walk (if needed)\n dirnames[i] = os.path.basename(new_dir_path)

def search_files(directory, search_term):
    # Walk through all directories and files
    print()  
    print(f'searching for {search_term}')
    for root, _, files in os.walk(directory):
        for file in files:
            path = os.path.join(root, file)
            try:
                # Open file in text mode with utf-8 encoding
                with open(path, 'r', encoding='utf-8') as f:
                    content = f.read()
                if search_term.lower() in content.lower():
                    print(f'Found in: {path}')
            except Exception as e:
                # Skip files that can't be read (binary files, permission issues, etc.)
                pass

if __name__ == '__main__':
    root_directory = '.'
    
    old_string_ = 'food'
    old_string = old_string_
    new_string = 'broka'
    skip_files = ['z_projects_list.txt', 'manipulator.py']
    skip_dirs = ['lib']  
    
    term_to_search = old_string_
    search_directory = '.'
    process_directory(root_directory, old_string, new_string, skip_files, skip_dirs)
    search_files(search_directory, term_to_search)


# if __name__ == '__main__':
#     # Change '.' to any specific directory if needed





# if __name__ == '__main__':
#     root_directory = '.'
#     broka
#     old_string_ = 'nouva_neo_n_3'
#     old_string = old_string_
#     new_string = 'nthungi_app'
#     skip_files = ['z_projects_list.txt', 'manipulator.py']
#     skip_dirs = ['lib']  
    
#     term_to_search = old_string_
#     search_directory = '.'
#     process_directory(root_directory, old_string, new_string, skip_files, skip_dirs)
#     search_files(search_directory, term_to_search)

