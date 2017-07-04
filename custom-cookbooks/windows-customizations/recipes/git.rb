include_recipe 'git'

execute '"C:\Program Files\Git\bin\git" config --file "C:\Program Files\Git\mingw64\etc\gitconfig" core.autocrlf false'
execute '"C:\Program Files\Git\bin\git" config --file "C:\Program Files\Git\mingw64\etc\gitconfig" core.longpaths true'
