#include <iostream>
#include <vector>
#include <queue>
#include <cmath>
#include <algorithm>
#include <fstream>

using namespace std;

struct Edge {
    int to;
    double w;
};

const double INF_D = 1e100;

void runDijkstra(int src,
                 int idx,
                 const vector< vector<Edge> > &graph,
                 vector< vector<double> > &dist,
                 vector< vector<int> > &parent) {
    int N = (int)graph.size() - 1; 

    dist[idx].assign(N + 1, INF_D);
    parent[idx].assign(N + 1, -1);

    priority_queue< pair<double,int>,
                    vector< pair<double,int> >,
                    greater< pair<double,int> > > pq;

    dist[idx][src] = 0.0;
    pq.push(make_pair(0.0, src));

    while (!pq.empty()) {
        pair<double,int> cur = pq.top();
        pq.pop();
        double d = cur.first;
        int u = cur.second;

        if (d > dist[idx][u]) continue;

        for (size_t i = 0; i < graph[u].size(); i++) {
            int v = graph[u][i].to;
            double w = graph[u][i].w;
            if (dist[idx][v] > dist[idx][u] + w) {
                dist[idx][v] = dist[idx][u] + w;
                parent[idx][v] = u;
                pq.push(make_pair(dist[idx][v], v));
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

    int N, M, K;
    if (!(*in >> N >> M >> K)) {
        return 0;
    }

    vector<double> X(N + 1), Y(N + 1);
    for (int i = 1; i <= N; i++) {
        (*in) >> X[i] >> Y[i];
    }

    vector< vector<Edge> > graph(N + 1);
    for (int i = 0; i < M; i++) {
        int a, b;
        (*in) >> a >> b;
        double dx = X[a] - X[b];
        double dy = Y[a] - Y[b];
        double w = sqrt(dx * dx + dy * dy);
        graph[a].push_back(Edge{b, w});
        graph[b].push_back(Edge{a, w});
    }

    vector<int> stopRaw(K);
    for (int i = 0; i < K; i++) {
        (*in) >> stopRaw[i];
    }

    vector<int> stops;
    for (int i = 0; i < K; i++) {
        int v = stopRaw[i];
        if (v != 1 && v != N) {
            stops.push_back(v);
        }
    }

    sort(stops.begin(), stops.end());
    stops.erase(unique(stops.begin(), stops.end()), stops.end());

    vector<int> important;
    important.push_back(1);
    for (size_t i = 0; i < stops.size(); i++) {
        important.push_back(stops[i]);
    }
    if (N != 1) {
        important.push_back(N);
    }

    sort(important.begin(), important.end());
    important.erase(unique(important.begin(), important.end()), important.end());
    int R = (int)important.size();

    vector<int> idxOf(N + 1, -1);
    for (int i = 0; i < R; i++) {
        idxOf[important[i]] = i;
    }

    vector< vector<double> > dist(R, vector<double>(N + 1));
    vector< vector<int> > parent(R, vector<int>(N + 1));

    for (int i = 0; i < R; i++) {
        runDijkstra(important[i], i, graph, dist, parent);
    }

    vector<int> route;
    route.push_back(1);

    vector<bool> usedStop(stops.size(), false);
    int left = (int)stops.size();
    int cur = 1;

    while (left > 0) {
        int rid = idxOf[cur];
        int bestIdx = -1;
        double bestDist = INF_D;

        for (size_t i = 0; i < stops.size(); i++) {
            if (usedStop[i]) continue;
            int s = stops[i];
            double d = dist[rid][s];
            if (d < bestDist) {
                bestDist = d;
                bestIdx = (int)i;
            }
        }

        if (bestIdx == -1) {
            for (size_t i = 0; i < stops.size(); i++) {
                if (!usedStop[i]) {
                    route.push_back(stops[i]);
                    usedStop[i] = true;
                }
            }
            left = 0;
            break;
        } else {
            int nxt = stops[bestIdx];
            route.push_back(nxt);
            usedStop[bestIdx] = true;
            left--;
            cur = nxt;
        }
    }

    if (route.back() != N) {
        route.push_back(N);
    }

    vector<int> finalPath;
    finalPath.push_back(route[0]); 

    for (size_t i = 0; i + 1 < route.size(); i++) {
        int from = route[i];
        int to = route[i + 1];
        int rid = idxOf[from];

        if (dist[rid][to] >= INF_D * 0.5) {
            if (finalPath.back() != to) {
                finalPath.push_back(to);
            }
            continue;
        }

        vector<int> seg;
        int curV = to;
        while (curV != from && curV != -1) {
            seg.push_back(curV);
            curV = parent[rid][curV];
        }

        if (curV != from) {
            if (finalPath.back() != to) {
                finalPath.push_back(to);
            }
        } else {
            for (int j = (int)seg.size() - 1; j >= 0; j--) {
                finalPath.push_back(seg[j]);
            }
        }
    }

    (*out) << finalPath.size() << "\n";
    for (size_t i = 0; i < finalPath.size(); i++) {
        if (i > 0) (*out) << " ";
        (*out) << finalPath[i];
    }
    (*out) << "\n";

    return 0;
}
