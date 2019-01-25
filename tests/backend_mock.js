import { RequestMock } from 'testcafe';
import BackendRepository from './backend_repository';

const ORIGIN = 'http://shamus-twoxtwo.builtwithdark.localhost:8000';

function prepareResponse(response, content) {
  response.headers['Access-Control-Allow-Origin'] = '*';
  response.setBody(JSON.stringify(content));
}

function createBoard(request, response) {
  prepareResponse(response, BackendRepository.createBoard());
}

function findBoard(request, response) {
  const url = new URL(request.url);
  const pathSegments = url.pathname.split("/");

  prepareResponse(response, BackendRepository.findBoard(pathSegments[pathSegments.length - 1]));
}

function updateBoard(request, response) {
  const url = new URL(request.url);
  const pathSegments = url.pathname.split("/");
  const body = JSON.parse(request.body);
  const board = BackendRepository.updateBoard(pathSegments[pathSegments.length - 1], body);

  prepareResponse(response, board);
}

function createCard(request, response) {
  const body = JSON.parse(request.body);
  const board = BackendRepository.findBoard(body.boardId);
  const card = board.addCard(body.text);

  prepareResponse(response, card);
}

function removeCard(request, response) {
  const url = new URL(request.url);
  const pathSegments = url.pathname.split("/");
  const body = JSON.parse(request.body);
  const board = BackendRepository.findBoard(body.boardId);
  const card = board.findCard(pathSegments[pathSegments.length - 1]);
  board.removeCard(card)

  prepareResponse(response, card);
}

function createPlacement(request, response) {
  const body = JSON.parse(request.body);
  const board = BackendRepository.findBoard(body.boardId);
  const card = board.findCard(body.cardId);
  const placement = board.addPlacement(card, body.x, body.y);

  prepareResponse(response, placement);
}

function removePlacement(request, response) {
  return response;
}

function knownOrigin(url) {
  return url.origin === ORIGIN;
}

function knownRoute(method, url) {
  return handlerFor(method, url) != null;
}

function handlerFor(method, url) {
  const pathSegments = (url.pathname).split('/');
  let handle = null;

  if (pathSegments.length == 0) {
    return handle;
  }

  switch (pathSegments[1]) {
    case 'boards':
      if (pathSegments.length == 2 && method == 'post') {
        handle = createBoard;
      }

      if (pathSegments.length == 3 && method == 'get') {
        handle = findBoard;
      }

      if (pathSegments.length == 3 && method == 'post') {
        handle = updateBoard;
      }

      break;
    case 'cards':
      if (pathSegments.length == 2 && method == 'post') {
        handle = createCard;
      }

      if (pathSegments.length == 3 && method == 'delete') {
        handle = removeCard;
      }

      break;
    case 'placements':
      if (pathSegments.length == 2 && method == 'post') {
        handle = createPlacement;
      }

      if (pathSegments.length == 3 && method == 'delete') {
        handle = removePlacement;
      }

      break;
  }

  return handle;
}

const backendMock = RequestMock()
  .onRequestTo(request => {
    const method = request.method.toLowerCase();
    const url = new URL(request.url);

    return knownOrigin(url) && knownRoute(method, url);
  })
  .respond((request, response) => {
    const method = request.method.toLowerCase();
    const url = new URL(request.url);
    const handle = handlerFor(method, url);

    return handle(request, response);
  });

export default backendMock;
