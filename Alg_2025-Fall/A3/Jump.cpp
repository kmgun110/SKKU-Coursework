#include <iostream>
#include <vector>
#include <queue>
#include <unordered_map>
#include <cmath>
#include <fstream>

using namespace std;

struct Stone {
    int x;
    int y;
};

long long makeKey(int x, int y) {
    const int SHIFT = 20;
    long long key = ((long long)x << SHIFT) | (long long)y;
    return key;
}

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

    int n;
    int G;
    if (!(*in >> n >> G)) {
        return 0;
    }

    // stone 0: start (0,0)
    vector<Stone> stones(n + 1);
    stones[0].x = 0;
    stones[0].y = 0;

    for (int i = 1; i <= n; i++) {
        (*in) >> stones[i].x >> stones[i].y;
    }

    if (G <= 0) {
        (*out) << 0 << "\n";
        return 0;
    }

    unordered_map<long long, vector<int> > bucket;
    bucket.reserve(n * 2);

    for (int i = 0; i <= n; i++) {
        if (stones[i].x < 0 || stones[i].y < 0) continue;
        long long key = makeKey(stones[i].x, stones[i].y);
        bucket[key].push_back(i);
    }

    const double INF = 1e100;
    vector<double> dist(n + 1, INF);

    priority_queue< pair<double,int>, 
                    vector< pair<double,int> >,
                    greater< pair<double,int> > > pq;

    dist[0] = 0.0;
    pq.push(make_pair(0.0, 0));

    double best = INF;

    const int MAXC = 1000000;

    while (!pq.empty()) {
        pair<double,int> cur = pq.top();
        pq.pop();
        double d = cur.first;
        int u = cur.second;

        if (d > dist[u]) continue;

        if (stones[u].y >= G) {
            best = d;
            break;
        }

        int x = stones[u].x;
        int y = stones[u].y;

        for (int dx = -2; dx <= 2; dx++) {
            int nx = x + dx;
            if (nx < 0 || nx > MAXC) continue;
            for (int dy = -2; dy <= 2; dy++) {
                int ny = y + dy;
                if (ny < 0 || ny > MAXC) continue;
                if (dx == 0 && dy == 0) continue;

                long long key = makeKey(nx, ny);
                auto it = bucket.find(key);
                if (it == bucket.end()) continue;

                const vector<int>& vec = it->second;
                for (size_t k = 0; k < vec.size(); k++) {
                    int v = vec[k];
                    double xx = (double)stones[u].x - (double)stones[v].x;
                    double yy = (double)stones[u].y - (double)stones[v].y;
                    double w = sqrt(xx * xx + yy * yy);

                    if (dist[v] > dist[u] + w) {
                        dist[v] = dist[u] + w;
                        pq.push(make_pair(dist[v], v));
                    }
                }
            }
        }
    }

    if (best >= INF * 0.5) {
        (*out) << -1 << "\n";
        return 0;
    }

    long long answer = (long long)(best + 0.5);
    (*out) << answer << "\n";

    return 0;
}
