# Sardinas Patterson Algorithm
# This program checks if a set of
# codewords (mapped from source alphabets) is uniquely decodable

def suffix(a, b):
    if a.startswith(b):
        return a[len(b):]
    return None


def sardinas_patterson(codes):
    if (len(codes) != len(set(codes))):
        return False  # duplicate codewords present

    S = set()

    for w1 in codes:
        for w2 in codes:
            if w1 != w2:
                t = suffix(w1, w2)
                if t is not None:
                    S.add(t)

    seen = []

    while S:
        frozen_S = frozenset(S)
        if frozen_S in seen:
            return True  # cycle detected - uniquely decodable
        seen.append(frozen_S)
        next_S = set()

        for w1 in S:
            for w2 in codes:
                s1 = suffix(w1, w2)
                s2 = suffix(w2, w1)
                if s1 == "" or s2 == "":
                    return False
                if s1 is not None:
                    next_S.add(s1)
                if s2 is not None:
                    next_S.add(s2)

        S = next_S

    return True
