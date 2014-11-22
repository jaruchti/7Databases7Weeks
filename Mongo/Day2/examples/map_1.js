// Book example of a mapping function.  Emits the distinct digits in a phone number and country
// as a key (using the distinctDigits function from distinct_digits.js).  A count for this key is given as a value.

map = function() {
  var digits = distinctDigits(this);
  emit({digits: digits, country : this.components.country}, {count: 1});
}
