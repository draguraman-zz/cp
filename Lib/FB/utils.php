<?php

/**
 * @return the value at $index in $array or $default if $index is not set.
 */
function idx(array $array, $key, $default = null) {
  return array_key_exists($key, $array) ? $array[$key] : $default;
}

/**
 * This will echo $value after sanitizing any html tags in it.
 * This is for preventing XSS attacks.  You should use echoSafe whenever
 * you are echoing content that could possibly be malicious (i.e.
 * content from an external request). This does not sanitize javascript
 * or attributes
*/
function he($str) {
  return htmlentities($str, ENT_QUOTES);
}

function echoEntity($str) {
  return he($str);
}

/**
 * @return $value if $value is numeric, else null.  Use this to assert that
 *         a value (like a user id) is a number.
 */
function assertNumeric($value) {
  if (is_numeric($value)) {
    return $value;
  } else {
    return null;
  }
}
