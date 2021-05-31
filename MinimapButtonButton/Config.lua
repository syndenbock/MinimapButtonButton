local _, addon = ...;

addon.enums = {
  DIRECTIONS = {
    LEFT = 'LEFT',
    RIGHT = 'RIGHT',
    DOWN = 'DOWN',
    UP = 'UP',
  },
};

addon.config = {
  FRAME_STRATA = 'MEDIUM',
  FRAME_LEVEL = 7,
  BUTTON_EDGE_SIZE = 16,
  BUTTON_HEIGHT = 40,
  BUTTON_WIDTH = 40,
  EDGE_OFFSET = 4,
  BUTTONS_PER_ROW = 10,
  BUTTON_SPACING = 2,
  DIRECTION_MAJOR = addon.enums.DIRECTIONS.LEFT,
  DIRECTION_MINOR = addon.enums.DIRECTIONS.DOWN,
};
