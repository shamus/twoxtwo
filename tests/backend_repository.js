const uuidv1 = require('uuid/v1');

class Board {
  static default() {
    return new this({uuid: uuidv1(), xAxis: 'x', yAxis: 'y', cards: [], placements: {}});
  }

  constructor(data) {
    this.uuid = data.uuid;
    this.xAxis = data.xAxis;
    this.yAxis = data.yAxis;
    this.cards = data.cards;
    this.placements = data.placements;
  }

  findCard(uuid) {
    return this.cards.filter(card => card.uuid === uuid)[0];
  }

  addCard(text) {
    let card = Card.from(text);
    this.cards.push(card);

    return card;
  }

  removeCard(card) {
    let index = this.cards.indexOf(card);
    if (index == -1) {
      return false;
    }

    this.cards.splice(index, 1);
    return true;
  }

  addPlacement(card, x, y) {
    let placement = new Placement(x, y);
    this.placements[card.uuid] = placement;

    return placement;
  }

  removePlacement(card) {
    return delete this.placements[card.uuid];
  }
}

class Card {
  static from(text) {
    return new this({ uuid: uuidv1(), text: text});
  }

  constructor(data) {
    this.uuid = data.uuid;
    this.text = data.text;
  }
}

class Placement {
  constructor(x, y) {
    this.x = x;
    this.y = y;
  }
}

class BackendRepository {
  constructor() {
    this.boards = {};
  }

  createBoard() {
    let board = Board.default();
    this.boards[board.uuid] = board;

    return board;
  }

  findBoard(uuid) {
    return this.boards[uuid];
  }

  updateBoard(uuid, update) {
    let board = new Board({...this.findBoard(uuid), ...update});
    this.boards[board.uuid] = board;

    return board;
  }
}

const repository = new BackendRepository();
export default repository;
