// Generated by using Rcpp::compileAttributes() -> do not edit by hand
// Generator token: 10BE3573-1514-4C36-9D1C-5A225CD40393

#include <Rcpp.h>

using namespace Rcpp;

// orfs_as_IRanges
S4 orfs_as_IRanges(std::string& main_string, const std::string s, const std::string e, int minimumLength);
RcppExport SEXP _ORFik_orfs_as_IRanges(SEXP main_stringSEXP, SEXP sSEXP, SEXP eSEXP, SEXP minimumLengthSEXP) {
BEGIN_RCPP
    Rcpp::RObject rcpp_result_gen;
    Rcpp::RNGScope rcpp_rngScope_gen;
    Rcpp::traits::input_parameter< std::string& >::type main_string(main_stringSEXP);
    Rcpp::traits::input_parameter< const std::string >::type s(sSEXP);
    Rcpp::traits::input_parameter< const std::string >::type e(eSEXP);
    Rcpp::traits::input_parameter< int >::type minimumLength(minimumLengthSEXP);
    rcpp_result_gen = Rcpp::wrap(orfs_as_IRanges(main_string, s, e, minimumLength));
    return rcpp_result_gen;
END_RCPP
}
// orfs_as_List
List orfs_as_List(CharacterVector fastaSeqs, std::string startCodon, std::string stopCodon, int minimumLength);
RcppExport SEXP _ORFik_orfs_as_List(SEXP fastaSeqsSEXP, SEXP startCodonSEXP, SEXP stopCodonSEXP, SEXP minimumLengthSEXP) {
BEGIN_RCPP
    Rcpp::RObject rcpp_result_gen;
    Rcpp::RNGScope rcpp_rngScope_gen;
    Rcpp::traits::input_parameter< CharacterVector >::type fastaSeqs(fastaSeqsSEXP);
    Rcpp::traits::input_parameter< std::string >::type startCodon(startCodonSEXP);
    Rcpp::traits::input_parameter< std::string >::type stopCodon(stopCodonSEXP);
    Rcpp::traits::input_parameter< int >::type minimumLength(minimumLengthSEXP);
    rcpp_result_gen = Rcpp::wrap(orfs_as_List(fastaSeqs, startCodon, stopCodon, minimumLength));
    return rcpp_result_gen;
END_RCPP
}
// findORFs_fasta
S4 findORFs_fasta(std::string file, std::string startCodon, std::string stopCodon, int minimumLength, bool isCircular);
RcppExport SEXP _ORFik_findORFs_fasta(SEXP fileSEXP, SEXP startCodonSEXP, SEXP stopCodonSEXP, SEXP minimumLengthSEXP, SEXP isCircularSEXP) {
BEGIN_RCPP
    Rcpp::RObject rcpp_result_gen;
    Rcpp::RNGScope rcpp_rngScope_gen;
    Rcpp::traits::input_parameter< std::string >::type file(fileSEXP);
    Rcpp::traits::input_parameter< std::string >::type startCodon(startCodonSEXP);
    Rcpp::traits::input_parameter< std::string >::type stopCodon(stopCodonSEXP);
    Rcpp::traits::input_parameter< int >::type minimumLength(minimumLengthSEXP);
    Rcpp::traits::input_parameter< bool >::type isCircular(isCircularSEXP);
    rcpp_result_gen = Rcpp::wrap(findORFs_fasta(file, startCodon, stopCodon, minimumLength, isCircular));
    return rcpp_result_gen;
END_RCPP
}
// pmapFromTranscriptsCPP
List pmapFromTranscriptsCPP(const std::vector<int>& xStart, const std::vector<int>& xEnd, const std::vector<int>& transcriptStart, const std::vector<int>& transcriptEnd, const std::vector<int>& indices, const char& direction, const bool removeEmpty);
RcppExport SEXP _ORFik_pmapFromTranscriptsCPP(SEXP xStartSEXP, SEXP xEndSEXP, SEXP transcriptStartSEXP, SEXP transcriptEndSEXP, SEXP indicesSEXP, SEXP directionSEXP, SEXP removeEmptySEXP) {
BEGIN_RCPP
    Rcpp::RObject rcpp_result_gen;
    Rcpp::RNGScope rcpp_rngScope_gen;
    Rcpp::traits::input_parameter< const std::vector<int>& >::type xStart(xStartSEXP);
    Rcpp::traits::input_parameter< const std::vector<int>& >::type xEnd(xEndSEXP);
    Rcpp::traits::input_parameter< const std::vector<int>& >::type transcriptStart(transcriptStartSEXP);
    Rcpp::traits::input_parameter< const std::vector<int>& >::type transcriptEnd(transcriptEndSEXP);
    Rcpp::traits::input_parameter< const std::vector<int>& >::type indices(indicesSEXP);
    Rcpp::traits::input_parameter< const char& >::type direction(directionSEXP);
    Rcpp::traits::input_parameter< const bool >::type removeEmpty(removeEmptySEXP);
    rcpp_result_gen = Rcpp::wrap(pmapFromTranscriptsCPP(xStart, xEnd, transcriptStart, transcriptEnd, indices, direction, removeEmpty));
    return rcpp_result_gen;
END_RCPP
}

static const R_CallMethodDef CallEntries[] = {
    {"_ORFik_orfs_as_IRanges", (DL_FUNC) &_ORFik_orfs_as_IRanges, 4},
    {"_ORFik_orfs_as_List", (DL_FUNC) &_ORFik_orfs_as_List, 4},
    {"_ORFik_findORFs_fasta", (DL_FUNC) &_ORFik_findORFs_fasta, 5},
    {"_ORFik_pmapFromTranscriptsCPP", (DL_FUNC) &_ORFik_pmapFromTranscriptsCPP, 7},
    {NULL, NULL, 0}
};

RcppExport void R_init_ORFik(DllInfo *dll) {
    R_registerRoutines(dll, NULL, CallEntries, NULL, NULL);
    R_useDynamicSymbols(dll, FALSE);
}
