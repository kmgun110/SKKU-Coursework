#include <cstdio>
#include <iostream>
#include <vector>
#include <algorithm>
#include <fstream>

using namespace std;

struct Edge {
    int a;
    int b;
    long long c;
};

struct DisjointSet {
    vector<int> parent;
    vector<int> height;

    DisjointSet(int n) {
        parent.resize(n + 1);
        height.assign(n + 1, 0);
        for (int i = 0; i <= n; i++) {
            parent[i] = i;
        }
    }

    int findRoot(int x) {
        if (parent[x] == x) return x;
        parent[x] = findRoot(parent[x]);
        return parent[x];
    }

    bool merge(int x, int y) {
        x = findRoot(x);
        y = findRoot(y);
        if (x == y) return false;
        if (height[x] < height[y]) {
            parent[x] = y;
        } else if (height[x] > height[y]) {
            parent[y] = x;
        } else {
            parent[y] = x;
            height[x]++;
        }
        return true;
    }
};

int main(int argc, char* argv[]) {
    ios::sync_with_stdio(false);
    cin.tie(NULL);

    istream* in = &cin;
    ostream* out = &cout;
    ifstream fin;
    ofstream fout;

    if (argc == 3) {
        fin.open(argv[1]);
        fout.open(argv[2]);
        in = &fin;
        out = &fout;
    }

    int n, m;
    if (!(*in >> n >> m)) {
        return 0;
    }

    vector<Edge> edges(m);
    for (int i = 0; i < m; i++) {
        (*in) >> edges[i].a >> edges[i].b >> edges[i].c;
    }

    sort(edges.begin(), edges.end(), [](const Edge &e1, const Edge &e2) {
        return e1.c < e2.c;
    });

    DisjointSet dsu(n);
    long long answer = 0;
    int useEdge = 0;

    for (int i = 0; i < m; i++) {
        if (dsu.merge(edges[i].a, edges[i].b)) {
            answer += edges[i].c;
            useEdge++;
            if (useEdge == n - 1) break;
        }
    }

    (*out) << answer << "\n";

    return 0;
}
