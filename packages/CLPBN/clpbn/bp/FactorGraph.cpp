#include <set>
#include <vector>
#include <algorithm>

#include <iostream>
#include <fstream>
#include <sstream>

#include "FactorGraph.h"
#include "Factor.h"
#include "BayesNet.h"



FactorGraph::FactorGraph (const BayesNet& bn)
{
  const BnNodeSet& nodes = bn.getBayesNodes();
  for (unsigned i = 0; i < nodes.size(); i++) {
    FgVarNode* varNode = new FgVarNode (nodes[i]);
    addVariable (varNode);
  }

  for (unsigned i = 0; i < nodes.size(); i++) {
    const BnNodeSet& parents = nodes[i]->getParents();
    if (!(nodes[i]->hasEvidence() && parents.size() == 0)) {
      VarNodes neighs;
      neighs.push_back (varNodes_[nodes[i]->getIndex()]);
      for (unsigned j = 0; j < parents.size(); j++) {
        neighs.push_back (varNodes_[parents[j]->getIndex()]);
      }
      FgFacNode* fn = new FgFacNode (
          new Factor (neighs, nodes[i]->getDistribution()));
      addFactor (fn);
      for (unsigned j = 0; j < neighs.size(); j++) {
        addEdge (fn, static_cast<FgVarNode*> (neighs[j]));
      }
    }
  }
  setIndexes();
}



void
FactorGraph::readFromUaiFormat (const char* fileName)
{
   ifstream is (fileName);
  if (!is.is_open()) {
    cerr << "error: cannot read from file " + std::string (fileName) << endl;
    abort();
  }

  string line;
  while (is.peek() == '#' || is.peek() == '\n') getline (is, line);
  getline (is, line);
  if (line != "MARKOV") {
    cerr << "error: the network must be a MARKOV network " << endl;
    abort();
  }

  while (is.peek() == '#' || is.peek() == '\n') getline (is, line);
  unsigned nVars;
  is >> nVars;

  while (is.peek() == '#' || is.peek() == '\n') getline (is, line);
  vector<int> domainSizes (nVars);
  for (unsigned i = 0; i < nVars; i++) {
    unsigned ds;
    is >> ds;
    domainSizes[i] = ds;
  }

  while (is.peek() == '#' || is.peek() == '\n') getline (is, line);
  for (unsigned i = 0; i < nVars; i++) {
    addVariable (new FgVarNode (i, domainSizes[i]));
  }

  unsigned nFactors;
  is >> nFactors;
  for (unsigned i = 0; i < nFactors; i++) {
    while (is.peek() == '#' || is.peek() == '\n') getline (is, line);
    unsigned nFactorVars;
    is >> nFactorVars;
    VarNodes neighs;
    for (unsigned j = 0; j < nFactorVars; j++) {
      unsigned vid;
      is >> vid;
      FgVarNode* neigh = getFgVarNode (vid);
      if (!neigh) {
        cerr << "error: invalid variable identifier (" << vid << ")" << endl;
        abort();
      }
      neighs.push_back (neigh);
    }
    FgFacNode* fn = new FgFacNode (new Factor (neighs));
    addFactor (fn);
    for (unsigned j = 0; j < neighs.size(); j++) {
      addEdge (fn, static_cast<FgVarNode*> (neighs[j]));
    }
  }

  for (unsigned i = 0; i < nFactors; i++) {
    while (is.peek() == '#' || is.peek() == '\n') getline (is, line);
    unsigned nParams;
    is >> nParams;
    if (facNodes_[i]->getParameters().size() != nParams) {
      cerr << "error: invalid number of parameters for factor " ;
      cerr << facNodes_[i]->getLabel() ;
      cerr << ", expected: " << facNodes_[i]->getParameters().size();
      cerr << ", given: " << nParams << endl;
      abort();
    }
    ParamSet params (nParams);
    for (unsigned j = 0; j < nParams; j++) {
      double param;
      is >> param;
      params[j] = param;
    }
    if (NSPACE == NumberSpace::LOGARITHM) {
      Util::toLog (params);
    }
    facNodes_[i]->factor()->setParameters (params);
  }
  is.close();
  setIndexes();
}



void
FactorGraph::readFromLibDaiFormat (const char* fileName)
{
  ifstream is (fileName);
  if (!is.is_open()) {
    cerr << "error: cannot read from file " + std::string (fileName) << endl;
    abort();
  }

  string line;
  unsigned nFactors;

  while ((is.peek()) == '#') getline (is, line);
  is >> nFactors;

  if (is.fail()) {
    cerr << "error: cannot read the number of factors" << endl;
    abort();
  }

  getline (is, line);
  if (is.fail() || line.size() > 0) {
    cerr << "error: cannot read the number of factors" << endl;
    abort();
  }

  for (unsigned i = 0; i < nFactors; i++) {
    unsigned nVars;
    while ((is.peek()) == '#') getline (is, line);

    is >> nVars;
    VarIdSet vids;
    for (unsigned j = 0; j < nVars; j++) {
      VarId vid;
      while ((is.peek()) == '#') getline (is, line);
      is >> vid;
      vids.push_back (vid);
    }

    VarNodes neighs;
    unsigned nParams = 1;
    for (unsigned j = 0; j < nVars; j++) {
      unsigned dsize;
      while ((is.peek()) == '#') getline (is, line);
      is >> dsize;
      FgVarNode* var = getFgVarNode (vids[j]);
      if (var == 0) {
        var = new FgVarNode (vids[j], dsize);
        addVariable (var);
      } else {
        if (var->nrStates() != dsize) {
          cerr << "error: variable `" << vids[j] << "' appears in two or " ;
          cerr << "more factors with different domain sizes" << endl;
        }
      }
      neighs.push_back (var);
      nParams *= var->nrStates();
    }
    ParamSet params (nParams, 0);
    unsigned nNonzeros;
    while ((is.peek()) == '#')
    getline (is, line);
    is >> nNonzeros;

    for (unsigned j = 0; j < nNonzeros; j++) {
      unsigned index;
      Param val;
      while ((is.peek()) == '#') getline (is, line);
      is >> index;
      while ((is.peek()) == '#') getline (is, line);
      is >> val;
      params[index] = val;
    }
    reverse (neighs.begin(), neighs.end());
    if (NSPACE == NumberSpace::LOGARITHM) {
      Util::toLog (params);
    }
    FgFacNode* fn = new FgFacNode (new Factor (neighs, params));
    addFactor (fn);
    for (unsigned j = 0; j < neighs.size(); j++) {
      addEdge (fn, static_cast<FgVarNode*> (neighs[j]));
    }
  }
  is.close();
  setIndexes();
}



FactorGraph::~FactorGraph (void)
{
  for (unsigned i = 0; i < varNodes_.size(); i++) {
    delete varNodes_[i];
  }
  for (unsigned i = 0; i < facNodes_.size(); i++) {
    delete facNodes_[i];
  }
}



void
FactorGraph::addVariable (FgVarNode* vn)
{
  varNodes_.push_back (vn);
  vn->setIndex (varNodes_.size() - 1);
  indexMap_.insert (make_pair (vn->varId(), varNodes_.size() - 1));
}



void
FactorGraph::addFactor (FgFacNode* fn)
{
  facNodes_.push_back (fn);
  fn->setIndex (facNodes_.size() - 1);
}


void
FactorGraph::addEdge (FgVarNode* vn, FgFacNode* fn)
{
  vn->addNeighbor (fn);
  fn->addNeighbor (vn);
}



void
FactorGraph::addEdge (FgFacNode* fn, FgVarNode* vn)
{
  fn->addNeighbor (vn);
  vn->addNeighbor (fn);
}



VarNode*
FactorGraph::getVariableNode (VarId vid) const
{
  FgVarNode* vn = getFgVarNode (vid);
  assert (vn);
  return vn;
}



VarNodes
FactorGraph::getVariableNodes (void) const
{
  VarNodes vars;
  for (unsigned i = 0; i < varNodes_.size(); i++) {
    vars.push_back (varNodes_[i]);
  }
  return vars;
}



bool
FactorGraph::isTree (void) const
{
  return !containsCycle();
}



void
FactorGraph::setIndexes (void)
{
  for (unsigned i = 0; i < varNodes_.size(); i++) {
    varNodes_[i]->setIndex (i);
  }
  for (unsigned i = 0; i < facNodes_.size(); i++) {
    facNodes_[i]->setIndex (i);
  }
}



void
FactorGraph::freeDistributions (void)
{
  set<Distribution*> dists;
  for (unsigned i = 0; i < facNodes_.size(); i++) {
    dists.insert (facNodes_[i]->factor()->getDistribution());
  }
  for (set<Distribution*>::iterator it = dists.begin();
      it != dists.end(); it++) {
    delete *it;
  }
}



void
FactorGraph::printGraphicalModel (void) const
{
  for (unsigned i = 0; i < varNodes_.size(); i++) {
    cout << "VarId       = "   << varNodes_[i]->varId() << endl;
    cout << "Label       = "   << varNodes_[i]->label() << endl;
    cout << "Nr States   = "   << varNodes_[i]->nrStates() << endl;
    cout << "Evidence    = "   << varNodes_[i]->getEvidence() << endl;
    cout << "Factors     = " ;
    for (unsigned j = 0; j < varNodes_[i]->neighbors().size(); j++) {
      cout << varNodes_[i]->neighbors()[j]->getLabel() << " " ;
    }
    cout << endl << endl;
  }
  for (unsigned i = 0; i < facNodes_.size(); i++) {
    facNodes_[i]->factor()->printFactor();
    cout << endl;
  }
}



void
FactorGraph::exportToGraphViz (const char* fileName) const
{
  ofstream out (fileName);
  if (!out.is_open()) {
    cerr << "error: cannot open file to write at " ;
    cerr << "FactorGraph::exportToDotFile()" << endl;
    abort();
  }

  out << "graph \"" << fileName << "\" {" << endl;

  for (unsigned i = 0; i < varNodes_.size(); i++) {
    if (varNodes_[i]->hasEvidence()) {
      out << '"' << varNodes_[i]->label() << '"' ;
      out << " [style=filled, fillcolor=yellow]" << endl;
    }
  }

  for (unsigned i = 0; i < facNodes_.size(); i++) {
    out << '"' << facNodes_[i]->getLabel() << '"' ;
    out << " [label=\"" << facNodes_[i]->getLabel(); 
    out << "\"" << ", shape=box]" << endl;
  }

  for (unsigned i = 0; i < facNodes_.size(); i++) {
    const FgVarSet& myVars = facNodes_[i]->neighbors();
    for (unsigned j = 0; j < myVars.size(); j++) {
      out << '"' << facNodes_[i]->getLabel() << '"' ;
      out << " -- " ;
      out << '"' << myVars[j]->label() << '"' << endl;
    }
  }

  out << "}" << endl;
  out.close();
}



void
FactorGraph::exportToUaiFormat (const char* fileName) const
{
  ofstream out (fileName);
  if (!out.is_open()) {
    cerr << "error: cannot open file to write at " ;
    cerr << "FactorGraph::exportToUaiFormat()" << endl;
    abort();
  }

  out << "MARKOV" << endl;
  out << varNodes_.size() << endl;
  for (unsigned i = 0; i < varNodes_.size(); i++) {
    out << varNodes_[i]->nrStates() << " " ;
  }
  out << endl;

  out << facNodes_.size() << endl;
  for (unsigned i = 0; i < facNodes_.size(); i++) {
    const FgVarSet& factorVars = facNodes_[i]->neighbors();
    out << factorVars.size();
    for (unsigned j = 0; j < factorVars.size(); j++) {
      out << " " << factorVars[j]->getIndex();
    }
    out << endl;
  }

  for (unsigned i = 0; i < facNodes_.size(); i++) {
    const ParamSet& params = facNodes_[i]->getParameters();
    out << endl << params.size() << endl << " " ;
    for (unsigned j = 0; j < params.size(); j++) {
      out << params[j] << " " ;
    }
    out << endl;
  }

  out.close();
}



void
FactorGraph::exportToLibDaiFormat (const char* fileName) const
{
  ofstream out (fileName);
  if (!out.is_open()) {
    cerr << "error: cannot open file to write at " ;
    cerr << "FactorGraph::exportToLibDaiFormat()" << endl;
    abort();
  }
  out << facNodes_.size() << endl << endl;
  for (unsigned i = 0; i < facNodes_.size(); i++) {
    const FgVarSet& factorVars = facNodes_[i]->neighbors();
    out << factorVars.size() << endl;
    for (int j = factorVars.size() - 1; j >= 0; j--) {
      out << factorVars[j]->varId() << " " ;
    }
    out << endl;
    for (unsigned j = 0; j < factorVars.size(); j++) {
      out << factorVars[j]->nrStates() << " " ;
    }
    out << endl;
    const ParamSet& params = facNodes_[i]->factor()->getParameters();
    out << params.size() << endl;
    for (unsigned j = 0; j < params.size(); j++) {
      out << j << " " << params[j] << endl;
    }
    out << endl;
  }
  out.close();
}



bool
FactorGraph::containsCycle (void) const
{
  vector<bool> visitedVars (varNodes_.size(), false);
  vector<bool> visitedFactors (facNodes_.size(), false);
  for (unsigned i = 0; i < varNodes_.size(); i++) {
    int v = varNodes_[i]->getIndex();
    if (!visitedVars[v]) {
      if (containsCycle (varNodes_[i], 0, visitedVars, visitedFactors)) {
        return true;
      }
    }
  }
  return false;
}



bool
FactorGraph::containsCycle (const FgVarNode* v,
                            const FgFacNode* p,
                            vector<bool>& visitedVars,
                            vector<bool>& visitedFactors) const
{
  visitedVars[v->getIndex()] = true;
  const FgFacSet& adjacencies = v->neighbors();
  for (unsigned i = 0; i < adjacencies.size(); i++) {
    int w = adjacencies[i]->getIndex();
    if (!visitedFactors[w]) {
      if (containsCycle (adjacencies[i], v, visitedVars, visitedFactors)) {
        return true;
      }
    }
    else if (visitedFactors[w] && adjacencies[i] != p) {
      return true;
    }
  }
  return false; // no cycle detected in this component
}



bool
FactorGraph::containsCycle (const FgFacNode* v,
                            const FgVarNode* p,
                            vector<bool>& visitedVars,
                            vector<bool>& visitedFactors) const
{
  visitedFactors[v->getIndex()] = true;
  const FgVarSet& adjacencies = v->neighbors();
  for (unsigned i = 0; i < adjacencies.size(); i++) {
    int w = adjacencies[i]->getIndex();
    if (!visitedVars[w]) {
      if (containsCycle (adjacencies[i], v, visitedVars, visitedFactors)) {
        return true;
      }
    }
    else if (visitedVars[w] && adjacencies[i] != p) {
      return true;
    }
  }
  return false; // no cycle detected in this component
}

