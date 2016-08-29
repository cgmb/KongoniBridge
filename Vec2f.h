#pragma once

struct Vec2f {
	float x;
	float y;
};

inline Vec2f operator+(Vec2f l, Vec2f r) {
	Vec2f result = l;
	result.x += r.x;
	result.y += r.y;
	return result;
}

inline Vec2f operator-(Vec2f l, Vec2f r) {
	Vec2f result = l;
	result.x -= r.x;
	result.y -= r.y;
	return result;
}

inline Vec2f operator/(Vec2f l, float r) {
	Vec2f result = l;
	result.x /= r;
	result.y /= r;
	return result;
}

inline float dot(Vec2f l, Vec2f r) {
	return l.x*r.x + l.y*r.y;
}

inline float magnitude(Vec2f v) {
	return sqrt(v.x*v.x + v.y*v.y);
}
