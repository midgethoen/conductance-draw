@ = require('mho:std');

var words = [
  ['very', 'quite', 'disturbingly', 'satisfyingly', 'distinguishably'],
  ['large', 'small', 'digestable', 'weird', 'wrong'],
  ['football', 'fish', 'plate', 'horse', 'sandwich', 'ashtray'],
];
exports.newID = function(){
    var rand = a -> a[Math.floor(Math.random() * a.length)];
    return (words .. @map(rand)).join('-');
}
