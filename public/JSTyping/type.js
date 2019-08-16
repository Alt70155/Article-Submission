"use strict";

let useProblem = [];
let questionsNum = 0; //二次元配列での問題が何列目かのカウント
let charCodeIndex = 1; //何文字目かのカウント
let correctTypeCnt = 0; //正しく入力した数
let charTypingCnt = 0; //すべての入力数
let missTypeCnt = 0;
let timerId = NaN;
let timerCt = 60;
let meterWidth = 0; //連打メーターの幅の値
let isPushedShiftKey = false;
let isPushedKey = false;
const SHIFT_KEY_CODE = 16;
const SPACE_KEY_CODE = 32;
const MAX_METER_WIDTH = 625;

//Fisher–Yatesシャッフルアルゴリズムを使った配列シャッフル
Array.prototype.shuffle = function() {
  let w = this.length;
  while (w) {
    let j = Math.floor(Math.random() * w);
    let t = this[--w];
    this[w] = this[j];
    this[j] = t;
  }
}

let start = () => {
  easyProblem.shuffle();
  commonProblem.shuffle();
  useProblem = easyProblem; //序盤は簡単な問題のみ出題

  document.onkeydown = keydown;
  function keydown(e) {
    if (e.keyCode === SPACE_KEY_CODE) {
      nodeDelete("main-center");
      startTimer();
      counter.textContent = "Time: " + timerCt + "s";
      init();
    }
  }
}

let init = () => {
  if (questionsNum === 4) { //出した問題数が4になったらuseProblemの中身を更新し、普通の問題を出す
    useProblem = commonProblem;
  }
  createNode();
  document.onkeydown = keydown;
  document.onkeyup = releaseFunction;
}

function keydown(e) {
  let targetCharCode = useProblem[questionsNum][charCodeIndex];
  if (!isPushedShiftKey) { //shiftがfalseの時のみカウントアップ
    charTypingCnt++;
  }
  //大文字か小文字か判定
  //大文字の区別としてkeyCodeに+1000してあるため、そこで判定
  if (targetCharCode > 1000) {
    let n = targetCharCode - 1000;
    if(e.keyCode === SHIFT_KEY_CODE) {
      isPushedShiftKey = true;
    }
    if(e.keyCode === n) {
      isPushedKey = true;
    }
    if(!isPushedShiftKey === isPushedKey) { //先にshift以外が押された場合falseに
      isPushedKey = false;
    }
    if(isPushedKey && isPushedShiftKey) {
      ifCorrectFunc();
      updateCorrectContinueBar();
    }
  } else {
    //入力されたkeycodeが正しいかとshiftが押されていないかどうか比較
    if (e.keyCode === targetCharCode && !isPushedShiftKey) {
      ifCorrectFunc();
      //全て文字が入力されたら
      if (useProblem[questionsNum].length < charCodeIndex) {
        questionsNum++;
        charCodeIndex = 1;
        nodeDelete("main-center");
        setTimeout(init, 500);
        //寿司打を参考にして、少し遅く出るように変更。
      }
    }
  }
  if(!isPushedShiftKey) {
    updateCorrectContinueBar();
  }
}


function releaseFunction(e) {
  if(e.keyCode === 16) {
    isPushedShiftKey = false;
  }
  isPushedKey = false;
}

//DOM再構成と問題文の表示
let createNode = () => {
  let main_center = document.getElementById("main-center");
  let div_out = document.createElement("div");
  div_out.className = "out";
  let div_inner = document.createElement("div");
  div_inner.className = "inner";

  //createDocumentFragmentはパフォーマンスがcreateElementより良いらしいので変更
  let df = document.createDocumentFragment();
  for (let i = 0; i < useProblem[questionsNum].length; i += 2) {
    let elm = document.createElement("span");
    elm.className = "before";
    elm.appendChild(document.createTextNode(useProblem[questionsNum][i]));
    df.appendChild(elm);
  }
  div_inner.appendChild(df);
  div_out.appendChild(div_inner);
  main_center.appendChild(div_out);
}

let ifCorrectFunc = () => {
  charCodeIndex += 2;
  correctTypeCnt++;
  let newElm = document.querySelector(".before");
  newElm.className = "after";
}

let nodeDelete = (x) => {
  let target = document.getElementById(x);
  while (target.firstChild) {
    target.removeChild(target.firstChild);
  }
}

let startTimer = () => {
  timerId = setInterval(timerCountDown, 1000);
}

let timerCountDown = () => {
  timerCt--;
  if (timerCt === 0) {
    clearInterval(timerId);
    showResult();
  } else {
    counter.textContent = "Time: " + timerCt + "s";
  }
}

let showResult = () => {
  nodeDelete("content");
  let missTypeResult = charTypingCnt - correctTypeCnt;
  document.getElementById("result").style.display = "block";
  document.getElementById("score1").textContent = "正しく入力した数：" + correctTypeCnt;
  document.getElementById("score2").textContent = "ミスタイプ数：" + missTypeResult;
}

let updateCorrectContinueBar = () => {
  if(meterWidth >= MAX_METER_WIDTH) {
    meterWidth = 0;
  }
  let meterMain = document.getElementById("meter_main");
  //全て打ったキー数と正しく打ったキー数を引き算し、差が無ければカウントアップ
  //差が出たらカウントリセットし、missTypeCntに差を代入
  if(charTypingCnt - correctTypeCnt === missTypeCnt) {
    meterWidth = meterWidth + 5;
  } else {
    meterWidth = 0;
    missTypeCnt = charTypingCnt - correctTypeCnt;
  }
  switch (meterWidth) {
    case 125:
      timerCt = timerCt + 1;
      counter.textContent = "Time: " + timerCt + "s";
      break;
    case 250:
      timerCt = timerCt + 1;
      counter.textContent = "Time: " + timerCt + "s";
      break;
    case 375:
      timerCt = timerCt + 2;
      counter.textContent = "Time: " + timerCt + "s";
      break;
    case 500:
      timerCt = timerCt + 2;
      counter.textContent = "Time: " + timerCt + "s";
      break;
    case MAX_METER_WIDTH:
      timerCt = timerCt + 3;
      counter.textContent = "Time: " + timerCt + "s";
      break;
  }
  meterMain.style.width = meterWidth + "px";
}
