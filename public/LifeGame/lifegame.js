"use strict";

//判定用のフィールドは実際使うフィールドより一回り大きく設定
let currentState = [];
let currentNextState = [];
const JUDGE_FIELD_SIZE = 40;
const FIELD_SIZE = JUDGE_FIELD_SIZE - 1;
let sameAsBeforeCnt = 0;
let id = null;


const start = () => {
  if (id === null) id = setInterval(updateCellColor, 90);
}

const stop = () => {
  if (id !== null) {
    clearInterval(id);
    id = null;
  }
}

const init = () => {
  //tableを作成
  const table = document.getElementById("table");
  //一回り分の数を足してそこからカウント
  let ct = JUDGE_FIELD_SIZE + 1;
  for (let i = 1; i < FIELD_SIZE; i++) {
    const tr = document.createElement("tr");
    for (let j = 1; j < FIELD_SIZE; j++) {
      const td = document.createElement("td");
      td.id = `num${ct}`;
      //td一つ一つにonClick関数をセットして、クリックで色を塗れるようにする
      td.onclick = onClickFunc;
      tr.appendChild(td);
      ct++;
    }
    //外枠をスキップ
    ct += 2;
    table.appendChild(tr);
  }
  //初期値ゼロの二次元配列を作成
  currentState = JSON.parse(JSON.stringify((new Array(JUDGE_FIELD_SIZE)).fill((new Array(JUDGE_FIELD_SIZE)).fill(0))));
  //currentStateをNextに値渡しして配列を複製
  currentNextState = JSON.parse(JSON.stringify(currentState));
}

const onClickFunc = e => initPaintFunc(e.target.id);

const updateCellColor = () => {
  updateArrayToNextState().forEach((inArray, i) => {
    inArray.forEach((state, j) => {
      //添字からtd要素のidを計算
      const targetId = i * JUDGE_FIELD_SIZE + j;
      state ? paintBlack(`num${targetId}`) : paintWhite(`num${targetId}`);
    });
  });
}

const updateArrayToNextState = () => {
  for (let i = 1; i < FIELD_SIZE; i++) {
    for (let j = 1; j < FIELD_SIZE; j++) {
      const cellCountResult = lifeDeathJudge(i, j);
      if (currentState[i][j]) {
        cellCountResult === 2 || cellCountResult === 3 ? currentNextState[i][j] = 1 : currentNextState[i][j] = 0;
      } else {
        cellCountResult === 3 ? currentNextState[i][j] = 1 : currentNextState[i][j] = 0;
      }
    }
  }
  infinityLoopCheck();
  //配列を現在に上書き
  return currentState = JSON.parse(JSON.stringify(currentNextState));
}

const infinityLoopCheck = () => {
  //無限ループ防止に前回の配列の状態と100秒間同じだった場合止める
  const STOP_TIME = 1000;
  if (currentState.toString() === currentNextState.toString()) {
    sameAsBeforeCnt++;
    if (sameAsBeforeCnt === STOP_TIME) {
      stop();
      sameAsBeforeCnt = 0;
    }
  }
}

//自マスの周りの生死を判定して生存マスの数を返す
const lifeDeathJudge = (i, j) => {
  let aliveState = 0;
  const diffCoor = [-1, 0, 1];
  diffCoor.forEach(y => {
    diffCoor.forEach(x => {
      //現座標から周囲8方向の座標を計算
      const iy = i + y;
      const jx = j + x;
      //比較する座標が自分のマスだった場合をはじく
      if ((iy != i || jx != j) && currentState[iy][jx]) aliveState++;
    });
  });
  return aliveState;
}

//クリックで塗る時の関数
const initPaintFunc = (paintTileId) => {
  console.log(paintTileId)
  //IDから数字部分を取り出し、二次元配列の添字を求める
  //[num, 100].split("m")[1] / 40 = 100 / 40 = 2
  const i = Math.floor(paintTileId.split("m")[1] / JUDGE_FIELD_SIZE);
  const j = paintTileId.split("m")[1] % JUDGE_FIELD_SIZE;
  if (currentState[i][j]) {
    currentState[i][j] = 0;
    paintWhite(paintTileId);
  } else {
    currentState[i][j] = 1;
    paintBlack(paintTileId);
  }
}

const paintBlack = paintTileId => {
  const td = document.getElementById(paintTileId);
  if (td !== null) td.classList.add("black");
}

const paintWhite = paintTileId => {
  const td = document.getElementById(paintTileId);
  if (td !== null) td.classList.remove("black");
}

const clearCell = () => {
  if (id !== null) stop();
  currentState.forEach((inArray, i) => {
    inArray.forEach((x, j) => {
      if (currentState[i][j]) {
        currentState[i][j] = 0;
        const targetId = i * JUDGE_FIELD_SIZE + j;
        paintWhite(`num${targetId}`);
      }
    });
  });
}

const glider = () => {
  initPaintFunc("num83");
  initPaintFunc("num124");
  initPaintFunc("num164");
  initPaintFunc("num163");
  initPaintFunc("num162");
}

const theQueenBee = () => {
  initPaintFunc("num220");
  initPaintFunc("num221");
  initPaintFunc("num261");
  initPaintFunc("num260");
  initPaintFunc("num300");
  initPaintFunc("num301");
  initPaintFunc("num264");
  initPaintFunc("num304");
  initPaintFunc("num305");
  initPaintFunc("num265");
  initPaintFunc("num295");
  initPaintFunc("num336");
  initPaintFunc("num255");
  initPaintFunc("num215");
  initPaintFunc("num176");
  initPaintFunc("num136");
  initPaintFunc("num376");
  initPaintFunc("num175");
  initPaintFunc("num335");
  initPaintFunc("num294");
  initPaintFunc("num253");
  initPaintFunc("num214");
  initPaintFunc("num254");
  initPaintFunc("num245");
  initPaintFunc("num244");
  initPaintFunc("num284");
  initPaintFunc("num285");
}
