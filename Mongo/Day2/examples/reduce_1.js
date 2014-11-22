// Book example of a reduce function.  
// Reduces the values array by summing the count field.
// It is used to generate a total count of all phone numbers which contain
// the same digits.

reduce = function(key, values) {
  var total = 0;
  for(var i=0; i < values.length; i++) {
    total += values[i].count;
  }
  return { count : total };
}
