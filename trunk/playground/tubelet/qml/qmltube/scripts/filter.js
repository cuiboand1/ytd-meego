function containsFilterText() {
    var result = true;
    var filter = filterString;
    if (filterString != "") {
        console.log(filter)
        result = /filter/gi.test("Amy - Swimwear Model | Ideal World 290311");
    }
    return result;
}
