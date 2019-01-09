const app = Elm.Main.init({});

app.ports.dropCard.subscribe((placement) => {
  let graph = document.querySelector(".txt-graph svg");
  let coords = placement.coords;
  let graphBounds = graph.getBoundingClientRect();
  let translatedCoords = translateCoordinates(graph, coords);
  let containsX = (coords.x >= graphBounds.left && coords.x <= graphBounds.right && translatedCoords.x >= 0 && translatedCoords.x <= 1000 );
  let containsY = (coords.y >= graphBounds.top && coords.y <= graphBounds.bottom && translatedCoords.y >= 0 && translatedCoords.y <= 1000 );

  if (containsX && containsY) {
    placement.coords = translateCoordinates(graph, coords);
    app.ports.acceptPlacement.send(placement);
  } else {
    app.ports.rejectPlacement.send(placement);
  }
});

function translateCoordinates(svg, coords) {
  let pagePoint = svg.createSVGPoint();
  pagePoint.x = coords.x;
  pagePoint.y = coords.y;

  let svgPoint = pagePoint.matrixTransform(svg.getScreenCTM().inverse());
  return { x : svgPoint.x, y : svgPoint.y };
}
