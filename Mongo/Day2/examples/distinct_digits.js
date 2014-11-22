// Book example which returns an array with the distinct digits in a phone number.
// (e.g. 608-371-3333) -> [0, 1, 3, 6, 7, 8]

distinctDigits = function(phone){
  var
    number = phone.components.number + "",
    seen = [],
    result = [],
    i = number.length;
  while(i--){
    seen[+number[i]] = 1;
  }

  for (i=0; i<10; i++){
    if (seen[i]){
      result[result.length] = i;
    }
  }

  return result;
}

db.system.js.save({_id: 'distinctDigits', value: distinctDigits})
