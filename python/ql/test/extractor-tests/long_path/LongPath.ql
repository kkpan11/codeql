import python

/*
 * To avoid issues with having files with overly long path names checked into git (which causes problems on Windows),
 * this test depends on an autogenerated file being present.
 *
 * Specifically, the file
 *
 * really_rather_too_long_for_windows_path_length/with_unecessarily_longwinded_and_verbose_sub_folder/extremely_long_module_name_with_lots_of_digits_at_the_end_000000000000000000000000000000000000000000000000000000000000000000/test0000000000000000000000000000000000000000000000000000000.py
 *
 * should have been generated before running this test. See `_python_longpath_test_file_path` in `build`.
 *
 * If this test is still failing _despite_ the autogenerated file being present, then this suggests that there is some
 * problem in the extractor.
 */

from string message
where
  message = any(File f).toString()
  or
  not exists(File f) and
  message =
    "This test is failing because an autogenerated file is missing. Read the comment in the .ql file for more info."
select message
