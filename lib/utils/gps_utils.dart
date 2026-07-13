String getDirection(int degree) {
  if (degree >= 315 || degree < 45) {
    return 'Bắc';
  } else if (degree >= 45 && degree < 135) {
    return 'Đông';
  } else if (degree >= 135 && degree < 225) {
    return 'Nam';
  } else {
    return 'Tây';
  }
}
