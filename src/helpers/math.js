export function getOccurrencesSum(array) {
  return array.reduce((acc, { occur }) => acc + occur, 0)
}
