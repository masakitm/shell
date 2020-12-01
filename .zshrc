# コマンドの実行ごとに改行
function precmd() {
  # Print a newline before the prompt, unless it's the
  # first prompt in the process.
  if [ -z "$NEW_LINE_BEFORE_PROMPT" ]; then
    NEW_LINE_BEFORE_PROMPT=1
  elif [ "$NEW_LINE_BEFORE_PROMPT" -eq 1 ]; then
    echo ""
  fi
}

# プロンプトの色付け
export CLICOLOR=1
autoload -Uz compinit && compinit  # Gitの補完を有効化

# カラー
name_t='027m%}'      # user name text clolr
name_b='233m%}'    # user name background color
path_t='000m%}'     # path text clolr
path_b='026m%}'   # path background color
arrow='087m%}'   # arrow color
text_color='%{\e[38;5;'    # set text color
back_color='%{\e[30;48;5;' # set background color
reset='%{\e[0m%}'   # reset

color='%{\e[38;5;' #  文字色を設定
green='035m%}'
red='001m%}'
yellow='220m%}'
blue='033m%}'
cyan='244m%}'
violet='099m%}'
lemon='193m%}'
cursor='242m%}'
pink='177m%}'

# 文字
branch='\ue0a0'
sharp='\uE0B0'      # triangle

function left-prompt {
  user="${text_color}${name_t}@: "
  dir="${text_color}${violet}%~"
  tri="${text_color}${pink}»"

  echo "${user}${dir} ${tri} ${reset}"
}

# git ブランチ名を色付きで表示させるメソッド
function rprompt-git-current-branch {
  local branch_name st branch_status is_master

  if [ ! -e  ".git" ]; then
    # git 管理されていないディレクトリは何も返さない
    echo "\n${text_color}${cyan}$ ${reset}"
    return
  fi

  separater=""

  branch_name=`git rev-parse --abbrev-ref HEAD 2> /dev/null`
  st=`git status 2> /dev/null`

  if [[ -n `echo "$st" | grep "origin/master"` ]]
  then
    # masterの場合警告
    is_master="${color}${red}${separater} [this is master X]"
  fi

  if [[ -n `echo "$st" | grep "^Your branch is behind"` ]]
  then
    # ローカルが最新でない状態
    branch_status="${color}${yellow}${separater}[pull remote ↓]"

  elif [[ -n `echo "$st" | grep "^nothing to"` ]]
  then
    # 全て commit されてクリーンな状態
    branch_status="${color}${green}${separater}"

  elif [[ -n `echo "$st" | grep "^Untracked files"` ]]
  then
    # git 管理されていないファイルがある状態
    branch_status="${color}${violet}${separater}[new files to add ?]"
  
  elif [[ -n `echo "$st" | grep "^Changes not staged for commit"` ]]
  then
    # git add されていないファイルがある状態
    branch_status="${color}${lemon}${separater}[changes to add +]"
  
  elif [[ -n `echo "$st" | grep "^Changes to be committed"` ]]
  then
    # git commit されていないファイルがある状態
    branch_status="${color}${yellow}${separater}[changes to commit !]"
  
  elif [[ -n `echo "$st" | grep "^rebase in progress"` ]]
  then
    # git rebase中
    branch_status="${color}${red}${separater}[rebase in progress !](no branch)${reset}"
  
  else
    # 上記以外の状態の場合
    branch_status="${color}${blue}${separater} *"
  fi
  
  # ブランチ名を色付きで表示する
  echo "\n${is_master} ${branch_status}$branch_name ${reset}"
  echo "${text_color}${cyan}$ ${reset}"
}
 
# プロンプトが表示されるたびにプロンプト文字列を評価、置換する
setopt prompt_subst
 
# プロンプトの右側にメソッドの結果を表示させる
# RPROMPT='`rprompt-git-current-branch`'

PROMPT='`left-prompt``rprompt-git-current-branch`' 





# 再読み込み
alias sf='exec $SHELL -l'

# 色一覧
alias color='for c in {000..255}; do echo -n "\e[38;5;${c}m $c" ; [ $(($c%16)) -eq 15 ] && echo;done;echo'

# markdown
function md() {
  name=`date +%Y%m%d`

  if [ ! -e ~/git/memo/${name}.md ]
  then
    touch ~/git/memo/${name}.md
  fi
  
  vscode /Users/tomotsuka.masaki/git/memo/${name}.md
}

# react + ts環境作ってくれる君
function create-react() {
  current_path=$PWD

  # files
  touch main.js

  touch tsconfig.json
  echo -e '{\n  "compilerOptions": {\n    "target": "es2019",\n    "module": "esnext",\n    "moduleResolution": "node",\n    "jsx": "react",\n    "strict": true,\n    "esModuleInterop": true,\n    "forceConsistentCasingInFileNames": true\n  }\n}' >> ./tsconfig.json

  touch webpack.config.js
  echo -e 'const path = require("path")\nconst HTMLPlugin = require("html-webpack-plugin")\n\nmodule.exports = {\n  module: {\n    rules: [\n      {\n        test: /\.tsx?$/,\n        use: {\n          loader: "ts-loader",\n          options: {\n            transpileOnly: true,\n          },\n        },\n      }\n    ],\n  },\n  resolve: {\n    extensions: [".js", ".ts", ".tsx", ".json"]\n  },\n  plugins: [\n    new HTMLPlugin({\n      template: path.join(__dirname, "src/index.html"),\n    })\n  ]\n}\n' >> webpack.config.js

  touch .gitignore
  echo -e "/node_modules\n/dist\npackage-lock.json\nyarn-error.log\n.DS_Store" >> .gitignore

  # setup
  npm init
  npm i -D webpack webpack-cli webpack-dev-server typescript ts-loader html-webpack-plugin
  npm i -S react react-dom @types/react @types/react-dom

  # src
  mkdir src
  cd src

  touch index.html
  echo -e '<!DOCTYPE html><html lang="en"><head><meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1.0"><title>Document</title></head><body><div id="root"></div></body></html>' >> index.html

  touch index.tsx
  echo -e "import * as React from 'react'\nimport * as ReactDOM from 'react-dom'\nimport { App } from './components/App'\n\nconst root = document.getElementById('root')\n\nReactDOM.render(\n	<App />,\n	root\n)" >> index.tsx

  # hello world
  mkdir components
  cd components
  touch App.tsx
  echo -e "import * as React from 'react'\n\nexport function App() {\n	return (\n		<div>\n			<h1>Welcome to react app</h1>\n		</div>\n	)\n}" >> App.tsx

  # end
  cd $current_path
  rm main.js

  echo 'new react project ready'
  echo 'please add commands to package.json scripts'
  echo '  "dev": "webpack-cli serve --mode development"'
  echo '  "build": "webpack --mode production"'
}
