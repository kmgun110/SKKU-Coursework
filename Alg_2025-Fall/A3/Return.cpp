#include <iostream>
#include <vector>
#include <queue>
#include <cmath>
#include <fstream>

using namespace std;

struct Edge {
    int to;
    long long w;
};

void dijkstra(int start, const vector< vector<Edge> > &graph, vector<long long> &dist) {
    const long long INF = (long long)4e18;
    int V = (int)graph.size();
    dist.assign(V, INF);

    priority_queue< pair<long long,int>,
                    vector< pair<long long,int> >,
                    greater< pair<long long,int> > > pq;

    dist[start] = 0;
    pq.push(make_pair(0, start));

    while (!pq.empty()) {
        pair<long long,int> cur = pq.top();
        pq.pop();
        long long d = cur.first;
        int u = cur.second;

        if (d > dist[u]) continue;

        for (size_t i = 0; i < graph[u].size(); i++) {
            int v = graph[u][i].to;
            long long w = graph[u][i].w;
            if (dist[v] > dist[u] + w) {
                dist[v] = dist[u] + w;
                pq.push(make_pair(dist[v], v));
            }
        }
    }
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

    int N, M;
    if (!(*in >> N >> M)) {
        return 0;
    }

    int T;
    long long S;
    (*in) >> T >> S;

    vector< vector<int> > H(N, vector<int>(M));
    for (int i = 0; i < N; i++) {
        for (int j = 0; j < M; j++) {
            (*in) >> H[i][j];
        }
    }

    int V = N * M;
    vector< vector<Edge> > graph(V);
    vector< vector<Edge> > graphR(V); // reversed

    int di[4] = {0, 0, -1, 1};
    int dj[4] = {-1, 1, 0, 0};

    // (i,j) -> index
    auto getId = [M](int i, int j) {
        return i * M + j;
    };

    for (int i = 0; i < N; i++) {
        for (int j = 0; j < M; j++) {
            int u = getId(i, j);
            for (int k = 0; k < 4; k++) {
                int ni = i + di[k];
                int nj = j + dj[k];
                if (ni < 0 || ni >= N || nj < 0 || nj >= M) continue;

                int diff = H[ni][nj] - H[i][j];
                if (diff < 0) diff = -diff;
                if (diff > T) continue;

                int v = getId(ni, nj);
                long long cost;
                if (H[i][j] >= H[ni][nj]) {
                    cost = 1;
                } else {
                    long long d = (long long)H[ni][nj] - (long long)H[i][j];
                    cost = d * d;
                }

                graph[u].push_back(Edge{v, cost});
                graphR[v].push_back(Edge{u, cost});
            }
        }
    }

    vector<long long> distGo;
    vector<long long> distBack;

    int start = getId(0, 0);
    dijkstra(start, graph, distGo);
    dijkstra(start, graphR, distBack);

    int bestHeight = H[0][0];
    const long long INF = (long long)4e18;

    for (int i = 0; i < N; i++) {
        for (int j = 0; j < M; j++) {
            int v = getId(i, j);
            if (distGo[v] == INF || distBack[v] == INF) continue;
            long long totalCost = distGo[v] + distBack[v];
            if (totalCost <= S) {
                if (H[i][j] > bestHeight) {
                    bestHeight = H[i][j];
                }
            }
        }
    }

    (*out) << bestHeight << "\n";

    return 0;
}
