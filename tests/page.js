import { Selector } from 'testcafe';

async function updateAxis(controller, axis, value) {
  return controller
    .click(axis)
    .pressKey('backspace')
    .typeText(axis, value)
    .pressKey('enter');
}

export default class Page {
  constructor(controller) {
    this.controller = controller;
    this.form = {
      input: Selector('.txt-card__form-text'),
      button: Selector('.txt-card__form-button')
    };

    this.cards = Selector('.txt-cards .txt-card');
    this.graph = Selector('.txt-graph');
    this.xAxis = Selector('.txt-graph__x .txt-graph__axis-label');
    this.yAxis = Selector('.txt-graph__y .txt-graph__axis-label');
    this.placements = Selector('.txt-graph .txt-graph__placement-label');
  }

  async createCard(value) {
    return this.controller
      .click(this.form.input)
      .typeText(this.form.input, value)
      .click(this.form.button);
  }

  async removeCard(card) {
    return this.controller
      .hover(card)
      .click(card.child('.txt-card__delete'))
  }

  get lastCard() {
    return this.cards.nth(-1);
  }

  cardWithText(text) {
    return this.cards.withText(text);
  }

  updateXAxis(value) {
    return updateAxis(this.controller, this.xAxis, value);
  }

  updateYAxis(value) {
    return updateAxis(this.controller, this.yAxis, value);
  }

  placementWithText(text) {
    return this.placements.withText(text);
  }
}
