"use strict";

let yCoor = 0;
let xCoor = 0;
let prevValue = 0;

let init = (coordinatesArray) => {
  let pin = document.getElementById("pin");
  pin.style.visibility = "visible";
  coordinatesArray.shuffle();
  yCoor = coordinatesArray[0][0];
  xCoor = coordinatesArray[0][1];
}

//sanhokFunc
let sanhokCityRand = () => {
  init(SANHOKTOWNCOORVAL);
  if (yCoor === prevValue) {
    sanhokCityRand();
  }
  updatePinValue();
}

let sanhokNotBattleFieldRand = () => {
  init(SANHOKTOWNCOORVAL);
  //特定の座標の場合やり直し
  if (yCoor === prevValue || yCoor === PARADISE_Y || yCoor === RUINS_Y ||
     yCoor === BOOTCAMP_Y || yCoor === PAINAN_Y) {
    sanhokNotBattleFieldRand();
  }
  updatePinValue();
}

let sanhokDepopulateRand = () => {
  init(SANHOKDEPOCOORVAL);
  if (yCoor === prevValue) {
    sanhokDepopulateRand();
  }
  updatePinValue();
}

//erangelFunc
let erangelCityRand = () => {
  init(ERANGELTOWNCOORVAL);
  if (yCoor === prevValue) {
    erangelCityRand();
  }
  updatePinValue();
}

let erangelNotBattleFieldRand = () => {
  init(ERANGELTOWNCOORVAL);
  if (yCoor === YASUNAYA_Y || yCoor === SCHOOL_Y || yCoor === POCHINKI_Y ||
     yCoor === MILITARY_Y || yCoor === MANSHION_Y || yCoor === prevValue) {
    erangelNotBattleFieldRand();
  }
  updatePinValue();
}

//miramarFunc
let miramarCityRand = () => {
  init(MIRAMARTOWNCOORVAL);
  if (yCoor === prevValue) {
    miramarCityRand();
  }
  updatePinValue();
}

let miramarNotBattleFieldRand = () => {
  init(MIRAMARTOWNCOORVAL);
  if (yCoor === prevValue || yCoor === ELPOZO_Y || yCoor === SANMARTIN_Y || yCoor === DELPATRON_Y ||
     yCoor === ELAZAHAR_Y || yCoor === LOSLEONES_Y || yCoor === PECADO_Y) {
       miramarNotBattleFieldRand();
     }
  updatePinValue();
}

let updatePinValue = () => {
  let pin = document.getElementById("pin");
  pin.style.top = yCoor;
  pin.style.left = xCoor;
  //前回のピンのy座標を保持
  prevValue = yCoor;
}


//Fisher–Yatesアルゴリズムの配列シャッフル
Array.prototype.shuffle = function() {
  let w = this.length;
  while (w) {
    let j = Math.floor(Math.random() * w);
    let t = this[--w];
    this[w] = this[j];
    this[j] = t;
  }
}
