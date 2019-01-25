import backendMock from './backend_mock';
import Page from './page';

fixture `It's a graph y'all`
  .page `http://localhost:3000`
  .requestHooks(backendMock)

test('Working with a new 2x2', async controller => {
  const page = new Page(controller);

  await controller
    .expect(page.cards.count).eql(0)
    .expect(page.yAxis.value).eql('y')
    .expect(page.xAxis.value).eql('x');

  await page.updateYAxis('impact');
  await controller.expect(page.yAxis.value).eql('impact');

  await page.updateXAxis('effort');
  await controller.expect(page.xAxis.value).eql('effort');

  await page.createCard('feature a');
  await controller
    .expect(page.cards.count).eql(1)
    .expect(page.lastCard.textContent).eql('feature a');

  await page.createCard('feature b');
  await controller
    .expect(page.cards.count).eql(2)
    .expect(page.lastCard.textContent).eql('feature b');

  await page.createCard('feature c');
  await controller
    .expect(page.cards.count).eql(3)
    .expect(page.lastCard.textContent).eql('feature c');

  await controller
    .dragToElement(page.cardWithText('feature a'), page.graph)
    .expect(page.placements.count).eql(1)
    .expect(page.placementWithText('feature a').count).eql(1);

  await controller
    .dragToElement(page.cardWithText('feature b'), page.graph)
    .expect(page.placements.count).eql(2)
    .expect(page.placementWithText('feature b').count).eql(1);

  await page.removeCard(page.cardWithText('feature b'));
  await controller
    .expect(page.cards.count).eql(2)
    .expect(page.placements.count).eql(1);
});
