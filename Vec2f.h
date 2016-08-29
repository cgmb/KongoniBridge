#pragma once

struct Vec2f {
    float x;
    float y;

    Vec2f& operator+=(Vec2f r);
    Vec2f& operator-=(Vec2f r);
};

inline Vec2f& Vec2f::operator+=(Vec2f r) {
    this->x += r.x;
    this->y += r.y;
    return *this;
}

inline Vec2f operator+(Vec2f l, Vec2f r) {
    Vec2f result = l;
        result += r;
    return result;
}

inline Vec2f& Vec2f::operator-=(Vec2f r) {
    this->x -= r.x;
    this->y -= r.y;
    return *this;
}

inline Vec2f operator-(Vec2f l, Vec2f r) {
    Vec2f result = l;
        result -= r;
    return result;
}

inline Vec2f operator/(Vec2f l, float r) {
    Vec2f result = l;
    result.x /= r;
    result.y /= r;
    return result;
}

inline Vec2f operator*(Vec2f l, float r) {
        Vec2f result = l;
        result.x *= r;
        result.y *= r;
        return result;
}

inline float dot(Vec2f l, Vec2f r) {
    return l.x*r.x + l.y*r.y;
}

inline float magnitude(Vec2f v) {
    return sqrt(v.x*v.x + v.y*v.y);
}
