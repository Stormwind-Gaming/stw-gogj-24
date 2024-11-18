extends GutTest

const MathHelpers = preload("res://scripts/helpers/math.gd")

func test_scale_by_progress_mid_range():
	var result = MathHelpers.scale_by_progress(100.0, 50.5) # Actual midpoint
	assert_almost_eq(result, 100.0, 0.01) # Should be roughly unchanged at midpoint

	var result2 = MathHelpers.scale_by_progress(
		100.0,
		50.0,
		0.0, # progress_min
		100.0, # progress_max
		0.5, # scale_min
		1.5 # scale_max
	)
	assert_almost_eq(result2, 100.0, 0.01)

func test_scale_by_progress_minimum():
	var result = MathHelpers.scale_by_progress(100.0, 1.0) # Minimum progress
	assert_almost_eq(result, 50.0, 0.01) # Should be scaled by scale_min (0.5)

func test_scale_by_progress_maximum():
	var result = MathHelpers.scale_by_progress(100.0, 100.0) # Maximum progress
	assert_almost_eq(result, 150.0, 0.01) # Should be scaled by scale_max (1.5)

func test_scale_by_progress_custom_range():
	var result = MathHelpers.scale_by_progress(
		100.0, # base value
		5.0, # progress
		0.0, # progress_min
		10.0, # progress_max
		1.0, # scale_min
		2.0 # scale_max
	)
	assert_almost_eq(result, 150.0, 0.01) # Should be halfway between 100 and 200

func test_scale_by_progress_with_clamp():
	var result = MathHelpers.scale_by_progress(
		100.0, # base value
		100.0, # progress (maximum)
		1.0, # progress_min
		100.0, # progress_max
		0.5, # scale_min
		1.5, # scale_max
		0.0, # clamp_min
		120.0 # clamp_max
	)
	assert_almost_eq(result, 120.0, 0.01) # Should be clamped to 120

func test_scale_by_progress_out_of_bounds():
	var result = MathHelpers.scale_by_progress(100.0, 200.0) # Progress beyond max
	assert_almost_eq(result, 150.0, 0.01) # Should be clamped to maximum scaling
